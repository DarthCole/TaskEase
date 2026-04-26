import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../providers/task_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskProvider provider = context.watch<TaskProvider>();
    final AppSettings settings = provider.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          SwitchListTile(
            value: settings.soundEnabled,
            title: const Text('playing reminder sound'),
            subtitle: const Text('this toggle is enabling or muting reminder audio'),
            onChanged: (bool value) {
              provider.updateSettings(settings.copyWith(soundEnabled: value));
            },
          ),
          SwitchListTile(
            value: settings.hapticsEnabled,
            title: const Text('using haptics'),
            subtitle: const Text('this toggle is enabling vibration feedback'),
            onChanged: (bool value) {
              provider.updateSettings(settings.copyWith(hapticsEnabled: value));
            },
          ),
        ],
      ),
    );
  }
}
