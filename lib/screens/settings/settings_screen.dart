import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_controller.dart';
import '../../core/country_flag.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
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
    final locale = ref.watch(localeProvider);
    final l = AppL10n.of(context);

    void openEditor() => showPreferencesEditor(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // ── PREFERENCES ──────────────────────────────────────────────
            _SectionHeader(l.sectionPreferences),
            _SettingsCard(
              label: l.settingCountry,
              value: '${countryFlag(country)} $country',
              onTap: () => context.push(AppRoutes.countryPicker),
            ),
            const SizedBox(height: 8),
            _SettingsCard(
              label: l.settingWeekend,
              value: formatWeekend(weekend),
              onTap: openEditor,
            ),
            const SizedBox(height: 8),
            _SettingsCard(
              label: l.settingPtoBudget,
              value: l.daysValue(budget),
              onTap: openEditor,
            ),
            const SizedBox(height: 8),
            _SettingsCard(
              label: l.settingBreakLength,
              value: l.daysRange(range.min, range.max),
              onTap: openEditor,
            ),
            const SizedBox(height: 8),
            _SettingsCard(
              label: l.settingLanguage,
              value: locale == null
                  ? l.languageSystem
                  : (supportedLanguages[locale.languageCode] ??
                      locale.languageCode),
              onTap: () => _pickLanguage(context, ref, l),
            ),

            // ── APPEARANCE ───────────────────────────────────────────────
            _SectionHeader(l.sectionAppearance),
            _ThemeCard(mode: mode, ref: ref, l: l),

            // ── CALENDAR & REMINDERS (disabled placeholders) ─────────────
            _SectionHeader(l.sectionCalendar),
            Opacity(
              opacity: 0.5,
              child: _SettingsCard(
                label: l.appleCalendar,
                value: l.notConnected,
                onTap: null,
                showChevron: false,
              ),
            ),
            const SizedBox(height: 8),
            Opacity(
              opacity: 0.5,
              child: _SettingsCard(
                label: l.defaultReminder,
                value: '2 weeks before',
                onTap: null,
                showChevron: false,
              ),
            ),

            // ── ACCOUNT ──────────────────────────────────────────────────
            _SectionHeader(l.sectionAccount),
            const _AccountSection(),

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
  const _ThemeCard({required this.mode, required this.ref, required this.l});

  final ThemeMode mode;
  final WidgetRef ref;
  final AppL10n l;

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
          Text(l.settingTheme,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.system, label: Text(l.themeSystem)),
              ButtonSegment(value: ThemeMode.light, label: Text(l.themeLight)),
              ButtonSegment(value: ThemeMode.dark, label: Text(l.themeDark)),
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

// ─── _AccountSection ───────────────────────────────────────────────────────

class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final l = AppL10n.of(context);
    Widget signInCard() => _SettingsCard(
          label: l.signInCreateAccount,
          value: l.syncTagline,
          onTap: () => context.push(AppRoutes.auth),
        );
    return auth.when(
      loading: () =>
          _SettingsCard(label: l.sectionAccount, value: '…', showChevron: false),
      error: (_, _) => signInCard(),
      data: (state) {
        if (!state.isAuthenticated) return signInCard();
        final user = state.user!;
        return Column(
          children: [
            _SettingsCard(
              label: user.displayName?.isNotEmpty == true
                  ? user.displayName!
                  : l.authSignIn,
              value: '${user.email} · ${l.syncOn}',
              showChevron: false,
              trailing: const Icon(Icons.cloud_done, color: DaysoffColors.brandTeal),
            ),
            const SizedBox(height: 8),
            _DangerCard(
              label: l.logOut,
              onTap: () =>
                  ref.read(authControllerProvider.notifier).logout(),
            ),
            const SizedBox(height: 8),
            _DangerCard(
              label: l.deleteAccount,
              onTap: () => _confirmDelete(context, ref, l),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, AppL10n l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.deleteConfirmTitle),
        content: Text(l.deleteConfirmBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(l.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(l.delete,
                  style: const TextStyle(color: DaysoffColors.danger))),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authControllerProvider.notifier).deleteAccount();
    }
  }
}

class _DangerCard extends StatelessWidget {
  const _DangerCard({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: DaysoffColors.danger,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Language picker ─────────────────────────────────────────────────────────

Future<void> _pickLanguage(
    BuildContext context, WidgetRef ref, AppL10n l) async {
  final current = ref.read(localeProvider)?.languageCode;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text(l.languageSystem),
            trailing: current == null
                ? const Icon(Icons.check, color: DaysoffColors.brandTeal)
                : null,
            onTap: () {
              ref.read(localeProvider.notifier).state = null;
              Navigator.pop(sheet);
            },
          ),
          for (final e in supportedLanguages.entries)
            ListTile(
              title: Text(e.value),
              trailing: current == e.key
                  ? const Icon(Icons.check, color: DaysoffColors.brandTeal)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).state = Locale(e.key);
                Navigator.pop(sheet);
              },
            ),
        ],
      ),
    ),
  );
}
