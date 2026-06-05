import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/preferences_provider.dart';
import '../../providers/theme_mode_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/preferences_editor_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final budget = ref.watch(ptoBudgetProvider);
    final range = ref.watch(breakLengthProvider);
    final weekend = ref.watch(weekendProvider);
    void openEditor() => showPreferencesEditor(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          children: [
            const _SectionHeader('PREFERENCES'),
            const _ValueRow(label: 'Country of work', value: '🇰🇷 South Korea'),
            _ValueRow(label: 'Weekend', value: formatWeekend(weekend), onTap: openEditor),
            _ValueRow(label: 'PTO budget', value: '$budget days', onTap: openEditor),
            _ValueRow(
                label: 'Break length',
                value: '${range.min}–${range.max} days',
                onTap: openEditor),
            const _SectionHeader('APPEARANCE'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Theme', style: TextStyle(fontSize: 16)),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, label: Text('System')),
                      ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ],
                    selected: {mode},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) =>
                        ref.read(themeModeProvider.notifier).state = s.first,
                  ),
                ],
              ),
            ),
            const _SectionHeader('ABOUT'),
            const _ValueRow(label: 'Version', value: '0.1.0'),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: DaysoffColors.neutral500)),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value, this.onTap});
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text(value,
          style: const TextStyle(color: DaysoffColors.neutral700)),
      onTap: onTap,
    );
  }
}
