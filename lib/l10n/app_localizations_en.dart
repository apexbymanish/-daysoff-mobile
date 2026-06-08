// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get navHolidays => 'Holidays';

  @override
  String get navPlan => 'Plan';

  @override
  String get navSettings => 'Settings';

  @override
  String get planTitle => 'Plan your year';

  @override
  String get lengthBuffet => 'Length buffet';

  @override
  String get sandwichDays => 'Sandwich days';

  @override
  String get bestValueFound => 'Best value found';

  @override
  String get monthAll => 'All';

  @override
  String noBreakOptionsInMonth(String month) {
    return 'No break options in $month.';
  }

  @override
  String noSandwichDaysInMonth(String month) {
    return 'No sandwich days in $month.';
  }

  @override
  String get noBreaksForBudget =>
      'No breaks fit this budget. Try increasing it.';

  @override
  String get noSandwichDaysThisYear => 'No sandwich days this year.';

  @override
  String get sandwichHint =>
      'Single workdays wedged between days off — take one, gain a long weekend.';

  @override
  String takeDaysOff(int count) {
    return 'Take $count days off';
  }

  @override
  String get free => 'Free';

  @override
  String get absorbed => 'Absorbed';

  @override
  String get seeDetails => 'See details';

  @override
  String get saveAndRemind => 'Save + remind';

  @override
  String get saved => 'Saved';

  @override
  String get retry => 'Retry';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionPreferences => 'Preferences';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionCalendar => 'Calendar & reminders';

  @override
  String get sectionAccount => 'Account';

  @override
  String get settingCountry => 'Country of work';

  @override
  String get settingWeekend => 'Weekend';

  @override
  String get settingPtoBudget => 'PTO budget';

  @override
  String get settingBreakLength => 'Break length';

  @override
  String get settingTheme => 'Theme';

  @override
  String get settingLanguage => 'Language';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageSystem => 'System default';

  @override
  String get appleCalendar => 'Apple Calendar';

  @override
  String get notConnected => 'Not connected';

  @override
  String get defaultReminder => 'Default reminder';

  @override
  String daysValue(int count) {
    return '$count days';
  }

  @override
  String daysRange(int min, int max) {
    return '$min–$max days';
  }

  @override
  String get signInCreateAccount => 'Sign in / Create account';

  @override
  String get syncTagline => 'Sync your saved breaks across devices';

  @override
  String get logOut => 'Log out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get syncOn => 'sync on';

  @override
  String get deleteConfirmTitle => 'Delete account?';

  @override
  String get deleteConfirmBody =>
      'This permanently deletes your account and synced saved breaks.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authCreateHeading => 'Create your daysoff account';

  @override
  String get authTagline => 'Sync your saved breaks across devices.';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password (8+ characters)';

  @override
  String get fieldNameOptional => 'Name (optional)';

  @override
  String get authToggleToRegister => 'New here? Create an account';

  @override
  String get authToggleToLogin => 'Have an account? Sign in';

  @override
  String get authErrorCreds => 'Invalid email or password.';

  @override
  String get authErrorRegister =>
      'Could not create the account. The email may already be in use.';

  @override
  String get authErrorValidation =>
      'Enter an email and a password of 8+ characters.';
}
