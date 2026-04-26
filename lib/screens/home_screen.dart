import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import 'settings_screen.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openCreateTask(BuildContext context) async {
    final TaskItem? result = await Navigator.of(context).push<TaskItem>(
      MaterialPageRoute<TaskItem>(
        builder: (_) => const TaskFormScreen(),
      ),
    );
    if (result == null || !context.mounted) return;

    await context.read<TaskProvider>().addTask(
          title: result.title,
          note: result.note,
          dueAt: result.dueAt,
          priority: result.priority,
        );
  }

  Future<void> _openEditTask(BuildContext context, TaskItem task) async {
    final TaskItem? result = await Navigator.of(context).push<TaskItem>(
      MaterialPageRoute<TaskItem>(
        builder: (_) => TaskFormScreen(initialTask: task),
      ),
    );
    if (result == null || !context.mounted) return;

    await context.read<TaskProvider>().updateTask(
          task.copyWith(
            title: result.title,
            note: result.note,
            dueAt: result.dueAt,
            priority: result.priority,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final TaskProvider provider = context.watch<TaskProvider>();
    final List<TaskItem> tasks = provider.filteredTasks;
    final DateFormat formatter = DateFormat('EEE, MMM d - hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('rempo'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateTask(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: provider.setSearchQuery,
              decoration: const InputDecoration(
                labelText: 'search by title or note',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: <Widget>[
                ChoiceChip(
                  label: const Text('all'),
                  selected: provider.statusFilter == TaskFilter.all,
                  onSelected: (_) => provider.setStatusFilter(TaskFilter.all),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('pending'),
                  selected: provider.statusFilter == TaskFilter.pending,
                  onSelected: (_) => provider.setStatusFilter(TaskFilter.pending),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('completed'),
                  selected: provider.statusFilter == TaskFilter.completed,
                  onSelected: (_) => provider.setStatusFilter(TaskFilter.completed),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('priority: any'),
                  selected: provider.priorityFilter == null,
                  onSelected: (_) => provider.setPriorityFilter(null),
                ),
                for (final TaskPriority priority in TaskPriority.values) ...<Widget>[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(priority.name),
                    selected: provider.priorityFilter == priority,
                    onSelected: (_) => provider.setPriorityFilter(priority),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Text('no tasks matching your filters'),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      final TaskItem task = tasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        child: ListTile(
                          onTap: () => _openEditTask(context, task),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration:
                                  task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(formatter.format(task.dueAt)),
                              if (task.note.isNotEmpty) Text(task.note),
                            ],
                          ),
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (bool? value) {
                              context.read<TaskProvider>().toggleTaskCompletion(
                                    task,
                                    value ?? false,
                                  );
                            },
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (String value) async {
                              if (value == 'delete') {
                                await context.read<TaskProvider>().deleteTask(task.id);
                              } else if (value == 'edit') {
                                await _openEditTask(context, task);
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('edit'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('delete'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
