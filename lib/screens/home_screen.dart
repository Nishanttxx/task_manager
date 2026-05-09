import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../widgets/quote_card.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color ink = Color(0xFF0F0E0D);
  static const Color cream = Color(0xFFF7F4EF);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const QuoteCard(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'TODAY',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: ink.withValues(alpha: 0.4),
                ),
              ),
            ),
            Expanded(
              child: user == null
                  ? const Center(child: CircularProgressIndicator(color: ink))
                  : StreamBuilder<List<TaskModel>>(
                      stream: firestoreService.streamTasks(user.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: ink));
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        final tasks = snapshot.data ?? [];
                        if (tasks.isEmpty) {
                          return _buildEmptyState();
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return TaskTile(
                              task: task,
                              onToggle: () => firestoreService.toggleCompleted(user.uid, task),
                              onDelete: () => _confirmDelete(context, () => firestoreService.deleteTask(user.uid, task.id)),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AddTaskScreen(existingTask: task)),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTaskScreen()),
        ),
        backgroundColor: ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Tasks',
                style: GoogleFonts.syne(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, MMMM d').format(DateTime.now()),
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: ink.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: ink.withValues(alpha: 0.3)),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.grid_view_rounded, color: ink, size: 24),
          Icon(Icons.panorama_fish_eye_rounded, color: ink.withValues(alpha: 0.3), size: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist_rtl_rounded, size: 64, color: ink.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            'All clear for now!',
            style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w600, color: ink.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new task.',
            style: GoogleFonts.dmSans(fontSize: 14, color: ink.withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Sign Out?', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to sign out?', style: GoogleFonts.dmSans()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AuthService().signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Delete Task?', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
        content: Text('This action cannot be undone.', style: GoogleFonts.dmSans()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
