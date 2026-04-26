import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_settings.dart';
import '../models/task.dart';

class StorageService {
  static const String _taskBoxName = 'tasks_box';
  static const String _settingsBoxName = 'settings_box';
  static const String _settingsKey = 'app_settings';

  /// this method is bootstrapping local boxes before ui is loading.
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_taskBoxName);
    await Hive.openBox<Map>(_settingsBoxName);
  }

  static Box<Map> get _taskBox => Hive.box<Map>(_taskBoxName);
  static Box<Map> get _settingsBox => Hive.box<Map>(_settingsBoxName);

  static List<TaskItem> readTasks() {
    return _taskBox.values
        .map((Map<dynamic, dynamic> data) => TaskItem.fromMap(data))
        .toList()
      ..sort((TaskItem a, TaskItem b) => a.dueAt.compareTo(b.dueAt));
  }

  static Future<void> upsertTask(TaskItem task) async {
    await _taskBox.put(task.id, task.toMap());
  }

  static Future<void> deleteTask(String taskId) async {
    await _taskBox.delete(taskId);
  }

  static Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put(_settingsKey, settings.toMap());
  }

  static AppSettings readSettings() {
    return AppSettings.fromMap(_settingsBox.get(_settingsKey));
  }
}
