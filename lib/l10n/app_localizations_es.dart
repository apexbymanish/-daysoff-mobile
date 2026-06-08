// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppL10nEs extends AppL10n {
  AppL10nEs([String locale = 'es']) : super(locale);

  @override
  String get navHolidays => 'Festivos';

  @override
  String get navPlan => 'Planificar';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get planTitle => 'Planifica tu año';

  @override
  String get lengthBuffet => 'Por duración';

  @override
  String get sandwichDays => 'Días puente';

  @override
  String get bestValueFound => 'Mejor relación encontrada';

  @override
  String get monthAll => 'Todos';

  @override
  String noBreakOptionsInMonth(String month) {
    return 'No hay opciones de descanso en $month.';
  }

  @override
  String noSandwichDaysInMonth(String month) {
    return 'No hay días puente en $month.';
  }

  @override
  String get noBreaksForBudget =>
      'No breaks fit this budget. Try increasing it.';

  @override
  String get noSandwichDaysThisYear => 'No hay días puente este año.';

  @override
  String get sandwichHint =>
      'Días laborables sueltos entre días libres: toma uno y gana un fin de semana largo.';

  @override
  String takeDaysOff(int count) {
    return 'Toma $count días libres';
  }

  @override
  String get free => 'Gratis';

  @override
  String get absorbed => 'Absorbido';

  @override
  String get seeDetails => 'Ver detalles';

  @override
  String get saveAndRemind => 'Guardar + recordar';

  @override
  String get saved => 'Guardado';

  @override
  String get retry => 'Reintentar';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get sectionPreferences => 'Preferencias';

  @override
  String get sectionAppearance => 'Apariencia';

  @override
  String get sectionCalendar => 'Calendario y recordatorios';

  @override
  String get sectionAccount => 'Cuenta';

  @override
  String get settingCountry => 'País de trabajo';

  @override
  String get settingWeekend => 'Fin de semana';

  @override
  String get settingPtoBudget => 'Días de vacaciones';

  @override
  String get settingBreakLength => 'Duración del descanso';

  @override
  String get settingTheme => 'Tema';

  @override
  String get settingLanguage => 'Idioma';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get appleCalendar => 'Calendario de Apple';

  @override
  String get notConnected => 'No conectado';

  @override
  String get defaultReminder => 'Recordatorio predeterminado';

  @override
  String daysValue(int count) {
    return '$count días';
  }

  @override
  String daysRange(int min, int max) {
    return '$min–$max días';
  }

  @override
  String get signInCreateAccount => 'Iniciar sesión / Crear cuenta';

  @override
  String get syncTagline =>
      'Sincroniza tus descansos guardados entre dispositivos';

  @override
  String get logOut => 'Cerrar sesión';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get syncOn => 'sincronización activada';

  @override
  String get deleteConfirmTitle => '¿Eliminar cuenta?';

  @override
  String get deleteConfirmBody =>
      'Esto elimina permanentemente tu cuenta y los descansos guardados sincronizados.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authWelcomeBack => 'Bienvenido de nuevo';

  @override
  String get authCreateHeading => 'Crea tu cuenta de daysoff';

  @override
  String get authTagline =>
      'Sincroniza tus descansos guardados entre dispositivos.';

  @override
  String get fieldEmail => 'Correo electrónico';

  @override
  String get fieldPassword => 'Contraseña (8+ caracteres)';

  @override
  String get fieldNameOptional => 'Nombre (opcional)';

  @override
  String get authToggleToRegister => '¿Nuevo aquí? Crea una cuenta';

  @override
  String get authToggleToLogin => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get authErrorCreds => 'Correo o contraseña no válidos.';

  @override
  String get authErrorRegister =>
      'No se pudo crear la cuenta. El correo puede estar en uso.';

  @override
  String get authErrorValidation =>
      'Introduce un correo y una contraseña de 8+ caracteres.';
}
