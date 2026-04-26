import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.initialTask});

  final TaskItem? initialTask;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late DateTime _dueAt;
  late TaskPriority _priority;

  @override
  void initState() {
    super.initState();
    final TaskItem? task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _noteController = TextEditingController(text: task?.note ?? '');
    _dueAt = task?.dueAt ?? DateTime.now().add(const Duration(minutes: 5));
    _priority = task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDateTime() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 1);
    final DateTime lastDate = DateTime(now.year + 5);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueAt,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (!mounted || pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueAt),
    );
    if (!mounted || pickedTime == null) return;

    setState(() {
      _dueAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('title is required')),
      );
      return;
    }

    Navigator.of(context).pop<TaskItem>(
      TaskItem(
        id: widget.initialTask?.id ?? '',
        title: _titleController.text.trim(),
        note: _noteController.text.trim(),
        dueAt: _dueAt,
        priority: _priority,
        isCompleted: widget.initialTask?.isCompleted ?? false,
        isNotified: widget.initialTask?.isNotified ?? false,
        createdAt: widget.initialTask?.createdAt ?? DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.initialTask != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'edit task' : 'add task'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'note (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            title: const Text('due date and time'),
            subtitle: Text(_dueAt.toString()),
            trailing: const Icon(Icons.calendar_month),
            onTap: _pickDueDateTime,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<TaskPriority>(
            initialValue: _priority,
            decoration: const InputDecoration(
              labelText: 'priority',
              border: OutlineInputBorder(),
            ),
            items: TaskPriority.values
                .map(
                  (TaskPriority value) => DropdownMenuItem<TaskPriority>(
                    value: value,
                    child: Text(value.name),
                  ),
                )
                .toList(),
            onChanged: (TaskPriority? value) {
              if (value == null) return;
              setState(() => _priority = value);
            },
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.save),
            label: Text(isEditing ? 'save updates' : 'save task'),
          ),
        ],
      ),
    );
  }
}
