import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';
import '../services/alarm_service.dart';
import 'dart:io';

class AddTaskScreen extends StatefulWidget {
  final TaskModel? existingTask;

  const AddTaskScreen({super.key, this.existingTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _alarmService = AlarmService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isAlarmEnabled = false;
  String? _alarmTonePath;
  RepeatOption _repeatOption = RepeatOption.none;
  bool _isSaving = false;

  static const Color ink = Color(0xFF0F0E0D);
  static const Color cream = Color(0xFFF7F4EF);
  static const Color cream2 = Color(0xFFEDE9E2);
  static const Color accent = Color(0xFFD9440F);

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingTask?.title ?? '');
    _descriptionController = TextEditingController(text: widget.existingTask?.description ?? '');
    
    final initialDate = widget.existingTask?.date ?? DateTime.now();
    _selectedDate = initialDate;
    _selectedTime = TimeOfDay.fromDateTime(initialDate);
    
    _isAlarmEnabled = widget.existingTask?.isAlarmEnabled ?? false;
    _alarmTonePath = widget.existingTask?.alarmTonePath;
    _repeatOption = widget.existingTask?.repeatOption ?? RepeatOption.none;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _alarmService.stopAudio();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: _pickerTheme,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: _pickerTheme,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Widget _pickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(primary: accent, onPrimary: Colors.white, surface: Colors.white, onSurface: ink),
      ),
      child: child!,
    );
  }

  Future<void> _pickTone() async {
    final path = await _alarmService.pickAlarmTone();
    if (path != null) setState(() => _alarmTonePath = path);
  }

  Future<void> _testAlarm() async {
    if (_alarmTonePath != null) {
      await _alarmService.playTonePreview(_alarmTonePath!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No custom tone selected.')));
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    
    final finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (finalDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot set task in the past.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final task = TaskModel(
        id: _isEditing ? widget.existingTask!.id : '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: finalDateTime,
        completed: _isEditing ? widget.existingTask!.completed : false,
        isAlarmEnabled: _isAlarmEnabled,
        alarmTonePath: _alarmTonePath,
        repeatOption: _repeatOption,
      );

      if (_isEditing) {
        await _firestoreService.updateTask(user.uid, task);
      } else {
        await _firestoreService.addTask(user.uid, task);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close_rounded, color: ink), onPressed: () => Navigator.pop(context)),
        title: Text(_isEditing ? 'Edit Task' : 'New Task', style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: ink)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLabel('TITLE'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.dmSans(color: ink, fontSize: 16),
                decoration: _inputDecoration(hint: 'What needs to be done?'),
                validator: (val) => (val == null || val.isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 24),
              _buildLabel('DESCRIPTION'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                style: GoogleFonts.dmSans(color: ink, fontSize: 16),
                decoration: _inputDecoration(hint: 'Add some details…'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('DATE'),
                        const SizedBox(height: 8),
                        _buildPickerTile(
                          icon: Icons.calendar_today_rounded,
                          label: DateFormat('MMM d, yyyy').format(_selectedDate),
                          onTap: _pickDate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('TIME'),
                        const SizedBox(height: 8),
                        _buildPickerTile(
                          icon: Icons.access_time_rounded,
                          label: _selectedTime.format(context),
                          onTap: _pickTime,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('ALARM SETTINGS'),
              const SizedBox(height: 12),
              _buildAlarmCard(),
              const SizedBox(height: 48),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isEditing ? 'Update Task' : 'Create Task', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        _buildLabel(title),
        const Expanded(child: Padding(padding: EdgeInsets.only(left: 12), child: Divider(color: cream2))),
      ],
    );
  }

  Widget _buildAlarmCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cream2),
        boxShadow: [
          BoxShadow(
            color: ink.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isAlarmEnabled ? accent.withValues(alpha: 0.1) : cream2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isAlarmEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                color: _isAlarmEnabled ? accent : ink.withValues(alpha: 0.3),
                size: 20,
              ),
            ),
            title: Text('Enable Alarm', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 16)),
            subtitle: Text(
              _isAlarmEnabled ? 'You will be notified at the due time' : 'Notifications are disabled',
              style: GoogleFonts.dmSans(fontSize: 12, color: ink.withValues(alpha: 0.5)),
            ),
            trailing: Switch.adaptive(
              value: _isAlarmEnabled,
              activeColor: accent,
              onChanged: (val) => setState(() => _isAlarmEnabled = val),
            ),
          ),
          if (_isAlarmEnabled) ...[
            const Divider(height: 1, indent: 20, endIndent: 20, color: cream2),
            _buildAlarmSettingRow(
              icon: Icons.music_note_rounded,
              title: 'Alarm Tone',
              value: _alarmTonePath != null ? _alarmTonePath!.split('/').last : 'System Default',
              action: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: _pickTone,
                    child: Text('Change', style: GoogleFonts.dmSans(color: accent, fontWeight: FontWeight.w700)),
                  ),
                  if (_alarmTonePath != null)
                    IconButton(
                      icon: const Icon(Icons.play_circle_fill_rounded, color: accent, size: 28),
                      onPressed: _testAlarm,
                    ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 20, endIndent: 20, color: cream2),
            _buildAlarmSettingRow(
              icon: Icons.repeat_rounded,
              title: 'Repeat',
              value: _repeatOption.name.toUpperCase(),
              action: DropdownButton<RepeatOption>(
                value: _repeatOption,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: ink),
                items: RepeatOption.values.map((opt) => DropdownMenuItem(
                  value: opt,
                  child: Text(opt.name.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600)),
                )).toList(),
                onChanged: (val) => setState(() => _repeatOption = val!),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildAlarmSettingRow({required IconData icon, required String title, required String value, required Widget action}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          Icon(icon, color: ink.withValues(alpha: 0.4), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.dmSans(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w700, color: ink.withValues(alpha: 0.4))),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: ink), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }

  Widget _buildPickerTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: cream2)),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.dmSans(color: ink, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.dmSans(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: ink.withValues(alpha: 0.4)));
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: ink.withValues(alpha: 0.3)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cream2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cream2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ink, width: 1.5)),
    );
  }
}
