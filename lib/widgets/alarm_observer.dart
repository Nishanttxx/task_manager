import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';
import '../services/alarm_service.dart';

class AlarmObserver extends StatefulWidget {
  final Widget child;

  const AlarmObserver({super.key, required this.child});

  @override
  State<AlarmObserver> createState() => _AlarmObserverState();
}

class _AlarmObserverState extends State<AlarmObserver> {
  StreamSubscription<AlarmSettings>? _subscription;
  bool _isPopupShowing = false;
  final _firestoreService = FirestoreService();
  final _alarmService = AlarmService();

  @override
  void initState() {
    super.initState();
    _initAlarmListener();
  }

  void _initAlarmListener() {
    if (Alarm.android || Alarm.iOS) {
      _subscription = Alarm.ringStream.stream.listen((alarmSettings) {
        _handleAlarmRinging(alarmSettings);
      });

      // Check if an alarm is already ringing upon app start
      _checkActiveAlarms();
    }
  }

  Future<void> _checkActiveAlarms() async {
    final alarms = await Alarm.getAlarms();
    for (final alarm in alarms) {
      if (await Alarm.isRinging(alarm.id)) {
        _handleAlarmRinging(alarm);
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _handleAlarmRinging(AlarmSettings alarmSettings) async {
    if (_isPopupShowing) return; // Prevent multiple popups
    _isPopupShowing = true;

    final user = FirebaseAuth.instance.currentUser;
    TaskModel? ringingTask;

    if (user != null) {
      // Find the task matching the alarm ID
      try {
        final tasksStream = _firestoreService.streamTasks(user.uid);
        final tasks = await tasksStream.first;
        try {
          ringingTask = tasks.firstWhere((t) => t.id.hashCode == alarmSettings.id);
        } catch (_) {
          ringingTask = null;
        }
      } catch (e) {
        debugPrint('Error fetching task for alarm: $e');
      }
    }

    if (mounted) {
      await _showAlarmPopup(alarmSettings, ringingTask);
    }
    _isPopupShowing = false;
  }

  Future<void> _showAlarmPopup(AlarmSettings alarmSettings, TaskModel? task) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _AlarmPopupContent(
          alarmSettings: alarmSettings,
          task: task,
          onStop: () async {
            await Alarm.stop(alarmSettings.id);
            if (context.mounted) Navigator.pop(context);
          },
          onSnooze: () async {
            await Alarm.stop(alarmSettings.id);
            final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
            final newSettings = alarmSettings.copyWith(
              dateTime: snoozeTime,
            );
            await Alarm.set(alarmSettings: newSettings);
            if (context.mounted) Navigator.pop(context);
          },
          onComplete: () async {
            await Alarm.stop(alarmSettings.id);
            final user = FirebaseAuth.instance.currentUser;
            if (user != null && task != null) {
              await _firestoreService.toggleCompleted(user.uid, task);
            }
            if (context.mounted) Navigator.pop(context);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _AlarmPopupContent extends StatefulWidget {
  final AlarmSettings alarmSettings;
  final TaskModel? task;
  final VoidCallback onStop;
  final VoidCallback onSnooze;
  final VoidCallback onComplete;

  const _AlarmPopupContent({
    required this.alarmSettings,
    required this.task,
    required this.onStop,
    required this.onSnooze,
    required this.onComplete,
  });

  @override
  State<_AlarmPopupContent> createState() => _AlarmPopupContentState();
}

class _AlarmPopupContentState extends State<_AlarmPopupContent> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.task?.title ?? 'Scheduled Alarm';
    final taskTime = widget.task?.date ?? widget.alarmSettings.dateTime;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F4EF), // cream
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD9440F).withValues(alpha: 0.2), // accent
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ringing Animation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD9440F).withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFFD9440F),
                  size: 64,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shake(hz: 4, curve: Curves.easeInOut)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1.seconds, curve: Curves.easeInOut)
                  .then()
                  .scale(begin: const Offset(1.1, 1.1), end: const Offset(0.9, 0.9), duration: 1.seconds, curve: Curves.easeInOut),
              
              const SizedBox(height: 24),

              // Current Time
              Text(
                DateFormat('h:mm a').format(_currentTime),
                style: GoogleFonts.syne(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F0E0D),
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 8),

              // Task Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F0E0D),
                ),
              ),

              const SizedBox(height: 8),

              // Task Time
              Text(
                'Due at ${DateFormat('h:mm a').format(taskTime)}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0F0E0D).withValues(alpha: 0.5),
                ),
              ),

              const SizedBox(height: 48),

              // Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Stop Alarm Button
                  ElevatedButton(
                    onPressed: widget.onStop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9440F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Stop Alarm',
                      style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Snooze Button
                  OutlinedButton.icon(
                    onPressed: widget.onSnooze,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F0E0D),
                      side: const BorderSide(color: Color(0xFFEDE9E2), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.snooze_rounded, size: 20),
                    label: Text(
                      'Snooze 5 minutes',
                      style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mark as Completed Button
                  if (widget.task != null)
                    TextButton.icon(
                      onPressed: widget.onComplete,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF0F0E0D).withValues(alpha: 0.6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                      label: Text(
                        'Mark as Completed',
                        style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
