import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('ko'),
    Locale('pt'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @navHolidays.
  ///
  /// In en, this message translates to:
  /// **'Holidays'**
  String get navHolidays;

  /// No description provided for @navPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get navPlan;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan your year'**
  String get planTitle;

  /// No description provided for @lengthBuffet.
  ///
  /// In en, this message translates to:
  /// **'Length buffet'**
  String get lengthBuffet;

  /// No description provided for @sandwichDays.
  ///
  /// In en, this message translates to:
  /// **'Sandwich days'**
  String get sandwichDays;

  /// No description provided for @bestValueFound.
  ///
  /// In en, this message translates to:
  /// **'Best value found'**
  String get bestValueFound;

  /// No description provided for @monthAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get monthAll;

  /// No description provided for @noBreakOptionsInMonth.
  ///
  /// In en, this message translates to:
  /// **'No break options in {month}.'**
  String noBreakOptionsInMonth(String month);

  /// No description provided for @noSandwichDaysInMonth.
  ///
  /// In en, this message translates to:
  /// **'No sandwich days in {month}.'**
  String noSandwichDaysInMonth(String month);

  /// No description provided for @noBreaksForBudget.
  ///
  /// In en, this message translates to:
  /// **'No breaks fit this budget. Try increasing it.'**
  String get noBreaksForBudget;

  /// No description provided for @noSandwichDaysThisYear.
  ///
  /// In en, this message translates to:
  /// **'No sandwich days this year.'**
  String get noSandwichDaysThisYear;

  /// No description provided for @sandwichHint.
  ///
  /// In en, this message translates to:
  /// **'Single workdays wedged between days off — take one, gain a long weekend.'**
  String get sandwichHint;

  /// No description provided for @takeDaysOff.
  ///
  /// In en, this message translates to:
  /// **'Take {count} days off'**
  String takeDaysOff(int count);

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @absorbed.
  ///
  /// In en, this message translates to:
  /// **'Absorbed'**
  String get absorbed;

  /// No description provided for @seeDetails.
  ///
  /// In en, this message translates to:
  /// **'See details'**
  String get seeDetails;

  /// No description provided for @saveAndRemind.
  ///
  /// In en, this message translates to:
  /// **'Save + remind'**
  String get saveAndRemind;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get sectionPreferences;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar & reminders'**
  String get sectionCalendar;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @settingCountry.
  ///
  /// In en, this message translates to:
  /// **'Country of work'**
  String get settingCountry;

  /// No description provided for @settingWeekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get settingWeekend;

  /// No description provided for @settingPtoBudget.
  ///
  /// In en, this message translates to:
  /// **'PTO budget'**
  String get settingPtoBudget;

  /// No description provided for @settingBreakLength.
  ///
  /// In en, this message translates to:
  /// **'Break length'**
  String get settingBreakLength;

  /// No description provided for @settingTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingTheme;

  /// No description provided for @settingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingLanguage;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @appleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Apple Calendar'**
  String get appleCalendar;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @defaultReminder.
  ///
  /// In en, this message translates to:
  /// **'Default reminder'**
  String get defaultReminder;

  /// No description provided for @daysValue.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysValue(int count);

  /// No description provided for @daysRange.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} days'**
  String daysRange(int min, int max);

  /// No description provided for @signInCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in / Create account'**
  String get signInCreateAccount;

  /// No description provided for @syncTagline.
  ///
  /// In en, this message translates to:
  /// **'Sync your saved breaks across devices'**
  String get syncTagline;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @syncOn.
  ///
  /// In en, this message translates to:
  /// **'sync on'**
  String get syncOn;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and synced saved breaks.'**
  String get deleteConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authCreateHeading.
  ///
  /// In en, this message translates to:
  /// **'Create your daysoff account'**
  String get authCreateHeading;

  /// No description provided for @authTagline.
  ///
  /// In en, this message translates to:
  /// **'Sync your saved breaks across devices.'**
  String get authTagline;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password (8+ characters)'**
  String get fieldPassword;

  /// No description provided for @fieldNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get fieldNameOptional;

  /// No description provided for @authToggleToRegister.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get authToggleToRegister;

  /// No description provided for @authToggleToLogin.
  ///
  /// In en, this message translates to:
  /// **'Have an account? Sign in'**
  String get authToggleToLogin;

  /// No description provided for @authErrorCreds.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get authErrorCreds;

  /// No description provided for @authErrorRegister.
  ///
  /// In en, this message translates to:
  /// **'Could not create the account. The email may already be in use.'**
  String get authErrorRegister;

  /// No description provided for @authErrorValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter an email and a password of 8+ characters.'**
  String get authErrorValidation;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'fr',
    'id',
    'ko',
    'pt',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'es':
      return AppL10nEs();
    case 'fr':
      return AppL10nFr();
    case 'id':
      return AppL10nId();
    case 'ko':
      return AppL10nKo();
    case 'pt':
      return AppL10nPt();
    case 'vi':
      return AppL10nVi();
    case 'zh':
      return AppL10nZh();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
