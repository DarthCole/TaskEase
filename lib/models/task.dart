import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

/// this model is carrying one task item in local storage.
class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    required this.dueAt,
    required this.createdAt,
    this.note = '',
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    this.isNotified = false,
  });

  final String id;
  String title;
  String note;
  DateTime dueAt;
  TaskPriority priority;
  bool isCompleted;
  bool isNotified;
  DateTime createdAt;

  bool get isPending => !isCompleted;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'note': note,
      'dueAt': dueAt.millisecondsSinceEpoch,
      'priority': priority.name,
      'isCompleted': isCompleted,
      'isNotified': isNotified,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory TaskItem.fromMap(Map<dynamic, dynamic> map) {
    return TaskItem(
      id: map['id'] as String,
      title: map['title'] as String,
      note: (map['note'] ?? '') as String,
      dueAt: DateTime.fromMillisecondsSinceEpoch(map['dueAt'] as int),
      priority: TaskPriority.values.firstWhere(
        (TaskPriority value) => value.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: (map['isCompleted'] ?? false) as bool,
      isNotified: (map['isNotified'] ?? false) as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  TaskItem copyWith({
    String? title,
    String? note,
    DateTime? dueAt,
    TaskPriority? priority,
    bool? isCompleted,
    bool? isNotified,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      dueAt: dueAt ?? this.dueAt,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      isNotified: isNotified ?? this.isNotified,
      createdAt: createdAt,
    );
  }

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.low:
        return Colors.teal;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }
}
