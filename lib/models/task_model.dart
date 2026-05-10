import 'package:cloud_firestore/cloud_firestore.dart';

enum RepeatOption { none, daily, weekly }

/// Data model for a single task.
///
/// Each task is stored in Firestore at: users/{uid}/tasks/{taskId}
/// Fields: id, title, description, date, completed, isAlarmEnabled, alarmTonePath, repeatOption.
class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool completed;
  final bool isAlarmEnabled;
  final String? alarmTonePath;
  final RepeatOption repeatOption;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.completed = false,
    this.isAlarmEnabled = false,
    this.alarmTonePath,
    this.repeatOption = RepeatOption.none,
  });

  /// Creates a TaskModel from a Firestore document snapshot.
  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    return TaskModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completed: map['completed'] as bool? ?? false,
      isAlarmEnabled: map['isAlarmEnabled'] as bool? ?? false,
      alarmTonePath: map['alarmTonePath'] as String?,
      repeatOption: RepeatOption.values.firstWhere(
        (e) => e.toString() == map['repeatOption'],
        orElse: () => RepeatOption.none,
      ),
    );
  }

  /// Converts this model to a Map for Firestore writes.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'completed': completed,
      'isAlarmEnabled': isAlarmEnabled,
      'alarmTonePath': alarmTonePath,
      'repeatOption': repeatOption.toString(),
    };
  }

  /// Returns a copy of this TaskModel with the given fields replaced.
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    bool? completed,
    bool? isAlarmEnabled,
    String? alarmTonePath,
    RepeatOption? repeatOption,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      isAlarmEnabled: isAlarmEnabled ?? this.isAlarmEnabled,
      alarmTonePath: alarmTonePath ?? this.alarmTonePath,
      repeatOption: repeatOption ?? this.repeatOption,
    );
  }
}
