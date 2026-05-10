import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import 'alarm_service.dart';

/// Provides CRUD operations against Cloud Firestore.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AlarmService _alarmService = AlarmService();

  /// Reference to the user's tasks sub-collection.
  CollectionReference<Map<String, dynamic>> _tasksRef(String uid) {
    return _db.collection('users').doc(uid).collection('tasks');
  }

  // ──────────────────────────────────────────────
  // CREATE — Add a new task
  // ──────────────────────────────────────────────
  Future<void> addTask(String uid, TaskModel task) async {
    final docRef = await _tasksRef(uid).add(task.toMap());
    final newTask = task.copyWith(id: docRef.id);
    await _alarmService.syncTaskAlarm(newTask);
  }

  // ──────────────────────────────────────────────
  // READ — Stream of all tasks
  // ──────────────────────────────────────────────
  Stream<List<TaskModel>> streamTasks(String uid) {
    return _tasksRef(uid)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // ──────────────────────────────────────────────
  // UPDATE — Edit an existing task
  // ──────────────────────────────────────────────
  Future<void> updateTask(String uid, TaskModel task) async {
    if (task.id.isEmpty) {
      throw Exception('Cannot update task with empty ID');
    }
    await _tasksRef(uid).doc(task.id).update(task.toMap());
    await _alarmService.syncTaskAlarm(task);
  }

  // ──────────────────────────────────────────────
  // DELETE — Remove a task
  // ──────────────────────────────────────────────
  Future<void> deleteTask(String uid, String taskId) async {
    await _tasksRef(uid).doc(taskId).delete();
    await _alarmService.cancelAlarm(taskId);
  }

  // ──────────────────────────────────────────────
  // TOGGLE — Toggle completed status
  // ──────────────────────────────────────────────
  Future<void> toggleCompleted(String uid, TaskModel task) async {
    if (task.id.isEmpty) {
      throw Exception('Cannot toggle task with empty ID');
    }
    final newCompletedStatus = !task.completed;
    await _tasksRef(uid).doc(task.id).update({
      'completed': newCompletedStatus,
    });
    
    // If completed, cancel the alarm. If uncompleted, re-sync.
    if (newCompletedStatus) {
      await _alarmService.cancelAlarm(task.id);
    } else {
      await _alarmService.syncTaskAlarm(task.copyWith(completed: false));
    }
  }
}
