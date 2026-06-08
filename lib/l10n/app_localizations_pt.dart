// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppL10nPt extends AppL10n {
  AppL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get navHolidays => 'Feriados';

  @override
  String get navPlan => 'Planejar';

  @override
  String get navSettings => 'Definições';

  @override
  String get planTitle => 'Planeje o seu ano';

  @override
  String get lengthBuffet => 'Por duração';

  @override
  String get sandwichDays => 'Dias-ponte';

  @override
  String get bestValueFound => 'Melhor custo-benefício';

  @override
  String get monthAll => 'Todos';

  @override
  String noBreakOptionsInMonth(String month) {
    return 'Sem opções de descanso em $month.';
  }

  @override
  String noSandwichDaysInMonth(String month) {
    return 'Sem dias-ponte em $month.';
  }

  @override
  String get noBreaksForBudget =>
      'No breaks fit this budget. Try increasing it.';

  @override
  String get noSandwichDaysThisYear => 'Sem dias-ponte este ano.';

  @override
  String get sandwichHint =>
      'Dias úteis isolados entre folgas — tire um e ganhe um fim de semana prolongado.';

  @override
  String takeDaysOff(int count) {
    return 'Tire $count dias de folga';
  }

  @override
  String get free => 'Grátis';

  @override
  String get absorbed => 'Absorvido';

  @override
  String get seeDetails => 'Ver detalhes';

  @override
  String get saveAndRemind => 'Salvar + lembrar';

  @override
  String get saved => 'Salvo';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get settingsTitle => 'Definições';

  @override
  String get sectionPreferences => 'Preferências';

  @override
  String get sectionAppearance => 'Aparência';

  @override
  String get sectionCalendar => 'Calendário e lembretes';

  @override
  String get sectionAccount => 'Conta';

  @override
  String get settingCountry => 'País de trabalho';

  @override
  String get settingWeekend => 'Fim de semana';

  @override
  String get settingPtoBudget => 'Dias de férias';

  @override
  String get settingBreakLength => 'Duração do descanso';

  @override
  String get settingTheme => 'Tema';

  @override
  String get settingLanguage => 'Idioma';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get appleCalendar => 'Calendário Apple';

  @override
  String get notConnected => 'Não conectado';

  @override
  String get defaultReminder => 'Lembrete padrão';

  @override
  String daysValue(int count) {
    return '$count dias';
  }

  @override
  String daysRange(int min, int max) {
    return '$min–$max dias';
  }

  @override
  String get signInCreateAccount => 'Entrar / Criar conta';

  @override
  String get syncTagline =>
      'Sincronize seus descansos salvos entre dispositivos';

  @override
  String get logOut => 'Sair';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get syncOn => 'sincronização ativada';

  @override
  String get deleteConfirmTitle => 'Excluir conta?';

  @override
  String get deleteConfirmBody =>
      'Isto exclui permanentemente sua conta e os descansos salvos sincronizados.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get authSignIn => 'Entrar';

  @override
  String get authCreateAccount => 'Criar conta';

  @override
  String get authWelcomeBack => 'Bem-vindo de volta';

  @override
  String get authCreateHeading => 'Crie sua conta daysoff';

  @override
  String get authTagline =>
      'Sincronize seus descansos salvos entre dispositivos.';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldPassword => 'Senha (8+ caracteres)';

  @override
  String get fieldNameOptional => 'Nome (opcional)';

  @override
  String get authToggleToRegister => 'Novo por aqui? Crie uma conta';

  @override
  String get authToggleToLogin => 'Já tem conta? Entrar';

  @override
  String get authErrorCreds => 'E-mail ou senha inválidos.';

  @override
  String get authErrorRegister =>
      'Não foi possível criar a conta. O e-mail pode já estar em uso.';

  @override
  String get authErrorValidation =>
      'Insira um e-mail e uma senha de 8+ caracteres.';
}
