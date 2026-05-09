import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../widgets/quote_card.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';

/// The primary screen of the app (Step 7 in the architecture).
///
/// Layout:
///   - AppBar with title & logout
///   - QuoteCard (motivational quote from REST API)
///   - StreamBuilder → real-time task list from Firestore
///   - FAB (+) → navigates to AddTaskScreen in add mode
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Task Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white54),
            tooltip: 'Sign out',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // ── Motivational Quote Card ──
          const QuoteCard(),

          const SizedBox(height: 8),

          // ── Section Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'My Tasks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: StreamBuilder<List<TaskModel>>(
                    stream: user != null
                        ? firestoreService.streamTasks(user.uid)
                        : const Stream.empty(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return Text(
                        '$count',
                        style: const TextStyle(
                          color: Color(0xFF818CF8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Task List (real-time stream) ──
          Expanded(
            child: user == null
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  )
                : StreamBuilder<List<TaskModel>>(
                    stream: firestoreService.streamTasks(user.uid),
                    builder: (context, snapshot) {
                      // Loading state
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6C63FF),
                          ),
                        );
                      }

                      // Error state
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: Color(0xFFEF4444),
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Something went wrong',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(180),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${snapshot.error}',
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      final tasks = snapshot.data ?? [];

                      // Empty state
                      if (tasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.checklist_rounded,
                                color: Colors.white.withAlpha(40),
                                size: 72,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks yet',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(120),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap + to add your first task',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(70),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Task list
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskTile(
                            task: task,
                            onToggle: () {
                              firestoreService.toggleCompleted(
                                  user.uid, task);
                            },
                            onDelete: () {
                              _confirmDelete(
                                context,
                                () => firestoreService.deleteTask(
                                    user.uid, task.id),
                              );
                            },
                            onTap: () {
                              // Navigate to AddTaskScreen in edit mode
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddTaskScreen(existingTask: task),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      // ── FAB → Add Task ──
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
        },
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  /// Shows a confirmation dialog before logging out.
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Your tasks are saved in the cloud. You can sign back in anytime.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AuthService().signOut();
            },
            child: const Text('Sign Out',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog before deleting a task.
  void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Task?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}
