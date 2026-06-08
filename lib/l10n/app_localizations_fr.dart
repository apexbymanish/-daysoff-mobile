// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppL10nFr extends AppL10n {
  AppL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get navHolidays => 'Jours fériés';

  @override
  String get navPlan => 'Planifier';

  @override
  String get navSettings => 'Réglages';

  @override
  String get planTitle => 'Planifiez votre année';

  @override
  String get lengthBuffet => 'Par durée';

  @override
  String get sandwichDays => 'Jours de pont';

  @override
  String get bestValueFound => 'Meilleur rapport trouvé';

  @override
  String get monthAll => 'Tous';

  @override
  String noBreakOptionsInMonth(String month) {
    return 'Aucune option de congé en $month.';
  }

  @override
  String noSandwichDaysInMonth(String month) {
    return 'Aucun jour de pont en $month.';
  }

  @override
  String get noBreaksForBudget =>
      'No breaks fit this budget. Try increasing it.';

  @override
  String get noSandwichDaysThisYear => 'Aucun jour de pont cette année.';

  @override
  String get sandwichHint =>
      'Des jours ouvrés isolés entre deux jours de repos : prenez-en un, gagnez un long week-end.';

  @override
  String takeDaysOff(int count) {
    return 'Prenez $count jours de congé';
  }

  @override
  String get free => 'Gratuit';

  @override
  String get absorbed => 'Absorbé';

  @override
  String get seeDetails => 'Voir les détails';

  @override
  String get saveAndRemind => 'Enregistrer + rappel';

  @override
  String get saved => 'Enregistré';

  @override
  String get retry => 'Réessayer';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get sectionPreferences => 'Préférences';

  @override
  String get sectionAppearance => 'Apparence';

  @override
  String get sectionCalendar => 'Calendrier et rappels';

  @override
  String get sectionAccount => 'Compte';

  @override
  String get settingCountry => 'Pays de travail';

  @override
  String get settingWeekend => 'Week-end';

  @override
  String get settingPtoBudget => 'Jours de congé';

  @override
  String get settingBreakLength => 'Durée du congé';

  @override
  String get settingTheme => 'Thème';

  @override
  String get settingLanguage => 'Langue';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get languageSystem => 'Par défaut du système';

  @override
  String get appleCalendar => 'Calendrier Apple';

  @override
  String get notConnected => 'Non connecté';

  @override
  String get defaultReminder => 'Rappel par défaut';

  @override
  String daysValue(int count) {
    return '$count jours';
  }

  @override
  String daysRange(int min, int max) {
    return '$min–$max jours';
  }

  @override
  String get signInCreateAccount => 'Se connecter / Créer un compte';

  @override
  String get syncTagline =>
      'Synchronisez vos congés enregistrés sur tous vos appareils';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get syncOn => 'synchro activée';

  @override
  String get deleteConfirmTitle => 'Supprimer le compte ?';

  @override
  String get deleteConfirmBody =>
      'Cela supprime définitivement votre compte et les congés enregistrés synchronisés.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authWelcomeBack => 'Bon retour';

  @override
  String get authCreateHeading => 'Créez votre compte daysoff';

  @override
  String get authTagline =>
      'Synchronisez vos congés enregistrés sur tous vos appareils.';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldPassword => 'Mot de passe (8+ caractères)';

  @override
  String get fieldNameOptional => 'Nom (facultatif)';

  @override
  String get authToggleToRegister => 'Nouveau ici ? Créez un compte';

  @override
  String get authToggleToLogin => 'Vous avez un compte ? Connectez-vous';

  @override
  String get authErrorCreds => 'E-mail ou mot de passe invalide.';

  @override
  String get authErrorRegister =>
      'Impossible de créer le compte. L’e-mail est peut-être déjà utilisé.';

  @override
  String get authErrorValidation =>
      'Saisissez un e-mail et un mot de passe d’au moins 8 caractères.';
}
