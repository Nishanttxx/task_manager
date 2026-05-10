import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDE9E2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.completed ? const Color(0xFF1D7A4F) : Colors.transparent,
              border: task.completed
                  ? null
                  : Border.all(color: const Color(0xFF0F0E0D).withValues(alpha: 0.15), width: 2),
            ),
            alignment: Alignment.center,
            child: task.completed
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0F0E0D).withValues(alpha: task.completed ? 0.4 : 1.0),
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              'Due: ${DateFormat('MMM d, h:mm a').format(task.date)}',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: const Color(0xFF0F0E0D).withValues(alpha: 0.4),
              ),
            ),
            if (task.isAlarmEnabled) ...[
              const SizedBox(width: 8),
              Icon(Icons.notifications_active_outlined, size: 12, color: const Color(0xFFD9440F).withValues(alpha: 0.6)),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.completed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D7A4F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    color: const Color(0xFF1D7A4F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFEF4444)),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
