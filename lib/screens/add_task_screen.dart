import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

/// Screen for adding a new task or editing an existing one (Step 8).
///
/// In **add mode**: [existingTask] is null → creates a new task.
/// In **edit mode**: [existingTask] is provided → pre-fills form fields.
///
/// Contains:
///   - Title field (validated — required)
///   - Description field (maxLines: 3)
///   - Date picker with calendar icon
///   - Save Task button
///
/// On save: calls addTask() or updateTask() → Navigator.pop() → HomeScreen.
class AddTaskScreen extends StatefulWidget {
  final TaskModel? existingTask;

  const AddTaskScreen({super.key, this.existingTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  bool _isSaving = false;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingTask?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.existingTask?.description ?? '');
    _selectedDate = widget.existingTask?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Not authenticated');
      }

      final task = TaskModel(
        id: _isEditing ? widget.existingTask!.id : '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        completed: _isEditing ? widget.existingTask!.completed : false,
      );

      if (_isEditing) {
        await _firestoreService.updateTask(user.uid, task);
      } else {
        await _firestoreService.addTask(user.uid, task);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Title Field ──
              _buildLabel('Title'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _inputDecoration(
                  hint: 'What needs to be done?',
                  icon: Icons.title_rounded,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ── Description Field ──
              _buildLabel('Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _inputDecoration(
                  hint: 'Add some details…',
                  icon: Icons.description_rounded,
                ),
              ),

              const SizedBox(height: 24),

              // ── Date Picker ──
              _buildLabel('Due Date'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2D2D44)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xFF818CF8),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: Colors.white38,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── Save Button ──
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    disabledBackgroundColor:
                        const Color(0xFF6C63FF).withAlpha(100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Task' : 'Save Task',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withAlpha(180),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      prefixIcon: Icon(icon, color: const Color(0xFF818CF8), size: 20),
      filled: true,
      fillColor: const Color(0xFF1A1A2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2D2D44)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2D2D44)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Color(0xFFEF4444)),
    );
  }
}
