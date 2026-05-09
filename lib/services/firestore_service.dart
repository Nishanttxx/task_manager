import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

/// Provides CRUD operations against Cloud Firestore.
///
/// All data is scoped to the authenticated user via the path:
///   users/{uid}/tasks/{taskId}
///
/// Security rule (apply in Firebase Console):
///   allow read, write: if request.auth != null
///                      && request.auth.uid == userId;
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Reference to the user's tasks sub-collection.
  CollectionReference<Map<String, dynamic>> _tasksRef(String uid) {
    return _db.collection('users').doc(uid).collection('tasks');
  }

  // ──────────────────────────────────────────────
  // CREATE — Add a new task
  // ──────────────────────────────────────────────
  Future<void> addTask(String uid, TaskModel task) async {
    await _tasksRef(uid).add(task.toMap());
  }

  // ──────────────────────────────────────────────
  // READ — Stream of all tasks (real-time updates)
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
    await _tasksRef(uid).doc(task.id).update(task.toMap());
  }

  // ──────────────────────────────────────────────
  // DELETE — Remove a task
  // ──────────────────────────────────────────────
  Future<void> deleteTask(String uid, String taskId) async {
    await _tasksRef(uid).doc(taskId).delete();
  }

  // ──────────────────────────────────────────────
  // TOGGLE — Toggle completed status
  // ──────────────────────────────────────────────
  Future<void> toggleCompleted(String uid, TaskModel task) async {
    await _tasksRef(uid).doc(task.id).update({
      'completed': !task.completed,
    });
  }
}
