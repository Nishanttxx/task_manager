import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'notification_service.dart';
import '../models/task_model.dart';
import 'dart:io' as io;

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final NotificationService _notificationService = NotificationService();

  /// Picks an audio file from the device storage.
  Future<String?> pickAlarmTone() async {
    // Request permissions for audio access on Android
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if (await Permission.audio.request().isGranted || 
          await Permission.storage.request().isGranted) {
        // Permission granted
      } else {
        return null;
      }
    }

    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      // Web doesn't support file paths, so we return the name for UI display
      if (kIsWeb) return result.files.single.name;
      
      // On native platforms, return the actual file path
      final String? originalPath = result.files.single.path;
      if (originalPath != null) {
        try {
          // Copy to internal app directory to bypass Android Scoped Storage restrictions in background
          final directory = await getApplicationDocumentsDirectory();
          final fileName = p.basename(originalPath);
          final savedPath = p.join(directory.path, fileName);
          
          final io.File localFile = io.File(originalPath);
          await localFile.copy(savedPath);
          
          // For Android, alarm package prefers the absolute path
          // For iOS, the alarm package recommends relative path from Documents, but we'll try absolute first as it often works with audioplayers preview
          return savedPath;
        } catch (e) {
          debugPrint('Error copying file: $e');
          return originalPath; // Fallback to original path if copy fails
        }
      }
    }
    return null;
  }

  /// Plays a preview of the selected tone.
  Future<void> playTonePreview(String path) async {
    if (kIsWeb) return; 
    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(path));
  }

  /// Stops any playing audio.
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  /// Schedules or updates an alarm for a task.
  Future<void> syncTaskAlarm(TaskModel task) async {
    if (kIsWeb) return; // Alarms not supported on web

    final alarmId = task.id.hashCode;
    
    // Always stop existing alarm to refresh settings
    await Alarm.stop(alarmId);

    // If alarm is enabled and task is not completed, schedule it
    if (task.isAlarmEnabled && !task.completed && task.date.isAfter(DateTime.now())) {
      final alarmSettings = AlarmSettings(
        id: alarmId,
        dateTime: task.date,
        assetAudioPath: task.alarmTonePath,
        loopAudio: true,
        vibrate: true,
        volumeSettings: VolumeSettings.fade(
          volume: 0.8,
          fadeDuration: const Duration(seconds: 3), // Fade in over 3 seconds
          volumeEnforced: true,
        ),
        notificationSettings: NotificationSettings(
          title: 'Task Pending: ${task.title}',
          body: 'Complete your task now: ${task.description}',
          stopButton: 'Stop Alarm',
          icon: 'notification_icon',
        ),
      );

      await Alarm.set(alarmSettings: alarmSettings);
    }
  }

  /// Cancels an alarm for a task.
  Future<void> cancelAlarm(String taskId) async {
    if (kIsWeb) return;
    await Alarm.stop(taskId.hashCode);
  }

  /// Disposes resources.
  void dispose() {
    _audioPlayer.dispose();
  }
}
