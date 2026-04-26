import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:vibration/vibration.dart';

import '../models/app_settings.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

enum TaskFilter { all, pending, completed }

class TaskProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  final List<TaskItem> _tasks = <TaskItem>[];

  AppSettings _settings = const AppSettings();
  String _searchQuery = '';
  TaskFilter _statusFilter = TaskFilter.pending;
  TaskPriority? _priorityFilter;
  bool _isReady = false;

  bool get isReady => _isReady;
  AppSettings get settings => _settings;
  String get searchQuery => _searchQuery;
  TaskFilter get statusFilter => _statusFilter;
  TaskPriority? get priorityFilter => _priorityFilter;

  /// this method is loading tasks and settings from local storage.
  Future<void> initialize() async {
    _tasks
      ..clear()
      ..addAll(StorageService.readTasks());
    _settings = StorageService.readSettings();
    _isReady = true;

    // this loop is keeping reminders in sync each time app is starting.
    for (final TaskItem task in _tasks.where((TaskItem t) => !t.isCompleted)) {
      await NotificationService.scheduleTaskReminder(task, _settings);
    }
    notifyListeners();
  }

  List<TaskItem> get filteredTasks {
    Iterable<TaskItem> list = _tasks;

    switch (_statusFilter) {
      case TaskFilter.pending:
        list = list.where((TaskItem item) => !item.isCompleted);
      case TaskFilter.completed:
        list = list.where((TaskItem item) => item.isCompleted);
      case TaskFilter.all:
        break;
    }

    if (_priorityFilter != null) {
      list = list.where((TaskItem item) => item.priority == _priorityFilter);
    }

    final String query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where(
        (TaskItem item) =>
            item.title.toLowerCase().contains(query) ||
            item.note.toLowerCase().contains(query),
      );
    }

    return list.toList()..sort((TaskItem a, TaskItem b) => a.dueAt.compareTo(b.dueAt));
  }

  Future<void> addTask({
    required String title,
    required String note,
    required DateTime dueAt,
    required TaskPriority priority,
  }) async {
    final TaskItem task = TaskItem(
      id: _uuid.v4(),
      title: title.trim(),
      note: note.trim(),
      dueAt: dueAt,
      priority: priority,
      createdAt: DateTime.now(),
    );

    _tasks.add(task);
    await StorageService.upsertTask(task);
    await NotificationService.scheduleTaskReminder(task, _settings);
    await _runHapticIfEnabled();
    notifyListeners();
  }

  Future<void> updateTask(TaskItem updated) async {
    final int index = _tasks.indexWhere((TaskItem item) => item.id == updated.id);
    if (index == -1) return;

    _tasks[index] = updated;
    await StorageService.upsertTask(updated);
    await NotificationService.cancelTaskReminder(updated.id);
    if (!updated.isCompleted) {
      await NotificationService.scheduleTaskReminder(updated, _settings);
    }
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((TaskItem item) => item.id == taskId);
    await StorageService.deleteTask(taskId);
    await NotificationService.cancelTaskReminder(taskId);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(TaskItem task, bool done) async {
    final TaskItem updated = task.copyWith(isCompleted: done);
    await updateTask(updated);
    await _runHapticIfEnabled();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await StorageService.saveSettings(_settings);

    // this loop is re-scheduling all pending reminders with latest sound settings.
    for (final TaskItem task in _tasks.where((TaskItem t) => !t.isCompleted)) {
      await NotificationService.cancelTaskReminder(task.id);
      await NotificationService.scheduleTaskReminder(task, _settings);
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(TaskFilter filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? filter) {
    _priorityFilter = filter;
    notifyListeners();
  }

  Future<void> _runHapticIfEnabled() async {
    if (!_settings.hapticsEnabled) return;
    final bool canVibrate = await Vibration.hasVibrator();
    if (canVibrate) {
      await Vibration.vibrate(duration: 50);
    }
  }
}
