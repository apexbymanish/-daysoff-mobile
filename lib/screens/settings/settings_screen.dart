import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/country_flag.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/selection_provider.dart';
import '../../providers/theme_mode_provider.dart';
import '../../router/app_router.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/preferences_editor_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final budget = ref.watch(ptoBudgetProvider);
    final range = ref.watch(breakLengthProvider);
    final weekend = ref.watch(weekendProvider);
    final country = ref.watch(selectedCountryProvider);

    void openEditor() => showPreferencesEditor(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // ── PREFERENCES ──────────────────────────────────────────────
            _SectionHeader('PREFERENCES'),
            _SettingsCard(
              label: 'Country of work',
              value: '${countryFlag(country)} $country',
              onTap: () => context.push(AppRoutes.countryPicker),
            ),
            const SizedBox(height: 8),
            _SettingsCard(
              label: 'Weekend',
              value: formatWeekend(weekend),
              onTap: openEditor,
            ),
            const SizedBox(height: 8),
            _SettingsCard(
              label: 'PTO budget',
              value: '$budget days',
              onTap: openEditor,
            ),
            const SizedBox(height: 8),
            _SettingsCard(
              label: 'Break length',
              value: '${range.min}–${range.max} days',
              onTap: openEditor,
            ),

            // ── APPEARANCE ───────────────────────────────────────────────
            _SectionHeader('APPEARANCE'),
            _ThemeCard(mode: mode, ref: ref),

            // ── CALENDAR & REMINDERS (disabled placeholders) ─────────────
            _SectionHeader('CALENDAR & REMINDERS'),
            Opacity(
              opacity: 0.5,
              child: _SettingsCard(
                label: 'Apple Calendar',
                value: 'Not connected',
                onTap: null,
                showChevron: false,
              ),
            ),
            const SizedBox(height: 8),
            Opacity(
              opacity: 0.5,
              child: _SettingsCard(
                label: 'Default reminder',
                value: '2 weeks before',
                onTap: null,
                showChevron: false,
              ),
            ),

            // ── ACCOUNT (disabled placeholders) ──────────────────────────
            _SectionHeader('ACCOUNT'),
            Opacity(
              opacity: 0.5,
              child: _SettingsCard(
                label: 'Profile',
                value: '',
                onTap: null,
                showChevron: false,
                trailing: const Icon(
                  Icons.person,
                  color: DaysoffColors.neutral500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Opacity(
              opacity: 0.5,
              child: _SignOutCard(),
            ),

            // ── FOOTER ───────────────────────────────────────────────────
            const SizedBox(height: 32),
            Center(
              child: Text(
                'DAYSOFF V0.1.0 · $country',
                style: labelCaps(fontSize: 12, color: DaysoffColors.neutral500),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── _SectionHeader ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: labelCaps(fontSize: 12, color: DaysoffColors.neutral500),
      ),
    );
  }
}

// ─── _SettingsCard ─────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.label,
    required this.value,
    this.onTap,
    this.showChevron = true,
    this.trailing,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool showChevron;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    Widget trailingWidget;
    if (trailing != null) {
      trailingWidget = trailing!;
    } else if (showChevron && onTap != null) {
      trailingWidget = const Icon(
        Icons.chevron_right,
        color: DaysoffColors.neutral500,
      );
    } else {
      trailingWidget = const SizedBox.shrink();
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DaysoffColors.outlineVariant),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (value.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 13,
                          color: DaysoffColors.neutral700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailingWidget,
            ],
          ),
        ),
      ),
    );
  }
}

// ─── _ThemeCard ────────────────────────────────────────────────────────────

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.mode, required this.ref});

  final ThemeMode mode;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DaysoffColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Theme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
    );
  }
}

// ─── _SignOutCard ──────────────────────────────────────────────────────────

class _SignOutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DaysoffColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: const Center(
        child: Text(
          'Sign out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: DaysoffColors.danger,
          ),
        ),
      ),
    );
  }
}
