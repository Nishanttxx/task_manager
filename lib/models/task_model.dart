import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for a single task.
///
/// Each task is stored in Firestore at: users/{uid}/tasks/{taskId}
/// Fields: id, title, description, date, completed.
class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool completed;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.completed = false,
  });

  /// Creates a TaskModel from a Firestore document snapshot.
  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    return TaskModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completed: map['completed'] as bool? ?? false,
    );
  }

  /// Converts this model to a Map for Firestore writes.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'completed': completed,
    };
  }

  /// Returns a copy of this TaskModel with the given fields replaced.
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    bool? completed,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      completed: completed ?? this.completed,
    );
  }
}
