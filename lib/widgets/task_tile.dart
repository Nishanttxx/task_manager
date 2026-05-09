import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';

/// A reusable list tile widget for displaying a single task.
///
/// Features (as specified in the architecture):
///   - Checkbox → toggles completed status (UPDATE)
///   - Delete icon → removes the task (DELETE)
///   - Tap → opens edit mode (navigates to AddTaskScreen)
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: task.completed
            ? const Color(0xFF1A1A2E).withAlpha(180)
            : const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.completed
              ? const Color(0xFF22C55E).withAlpha(60)
              : const Color(0xFF2D2D44),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: task.completed
                  ? const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                    )
                  : null,
              border: task.completed
                  ? null
                  : Border.all(color: const Color(0xFF4B5563), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: task.completed
                ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: task.completed ? Colors.white38 : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration:
                task.completed ? TextDecoration.lineThrough : TextDecoration.none,
            decorationColor: Colors.white38,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: task.completed ? Colors.white24 : Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: task.completed
                      ? Colors.white24
                      : const Color(0xFF818CF8),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(task.date),
                  style: TextStyle(
                    color: task.completed
                        ? Colors.white24
                        : const Color(0xFF818CF8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFEF4444),
            size: 22,
          ),
          onPressed: onDelete,
          tooltip: 'Delete task',
        ),
      ),
    );
  }
}
