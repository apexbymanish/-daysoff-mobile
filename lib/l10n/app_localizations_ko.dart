// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppL10nKo extends AppL10n {
  AppL10nKo([String locale = 'ko']) : super(locale);

  @override
  String get navHolidays => '공휴일';

  @override
  String get navPlan => '계획';

  @override
  String get navSettings => '설정';

  @override
  String get planTitle => '올해 계획하기';

  @override
  String get lengthBuffet => '길이별 추천';

  @override
  String get sandwichDays => '샌드위치 데이';

  @override
  String get bestValueFound => '최고의 가성비';

  @override
  String get monthAll => '전체';

  @override
  String noBreakOptionsInMonth(String month) {
    return '$month에는 휴가 옵션이 없습니다.';
  }

  @override
  String noSandwichDaysInMonth(String month) {
    return '$month에는 샌드위치 데이가 없습니다.';
  }

  @override
  String get noBreaksForBudget =>
      'No breaks fit this budget. Try increasing it.';

  @override
  String get noSandwichDaysThisYear => '올해는 샌드위치 데이가 없습니다.';

  @override
  String get sandwichHint => '휴일 사이에 낀 평일 하루만 쓰면 긴 연휴가 됩니다.';

  @override
  String takeDaysOff(int count) {
    return '$count일 휴가 사용';
  }

  @override
  String get free => '무료';

  @override
  String get absorbed => '포함됨';

  @override
  String get seeDetails => '자세히 보기';

  @override
  String get saveAndRemind => '저장 + 알림';

  @override
  String get saved => '저장됨';

  @override
  String get retry => '다시 시도';

  @override
  String get settingsTitle => '설정';

  @override
  String get sectionPreferences => '환경설정';

  @override
  String get sectionAppearance => '화면';

  @override
  String get sectionCalendar => '캘린더 및 알림';

  @override
  String get sectionAccount => '계정';

  @override
  String get settingCountry => '근무 국가';

  @override
  String get settingWeekend => '주말';

  @override
  String get settingPtoBudget => '연차 일수';

  @override
  String get settingBreakLength => '휴가 길이';

  @override
  String get settingTheme => '테마';

  @override
  String get settingLanguage => '언어';

  @override
  String get themeSystem => '시스템';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get languageSystem => '시스템 기본값';

  @override
  String get appleCalendar => 'Apple 캘린더';

  @override
  String get notConnected => '연결 안 됨';

  @override
  String get defaultReminder => '기본 알림';

  @override
  String daysValue(int count) {
    return '$count일';
  }

  @override
  String daysRange(int min, int max) {
    return '$min–$max일';
  }

  @override
  String get signInCreateAccount => '로그인 / 계정 만들기';

  @override
  String get syncTagline => '저장한 휴가를 기기 간에 동기화';

  @override
  String get logOut => '로그아웃';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get syncOn => '동기화 켜짐';

  @override
  String get deleteConfirmTitle => '계정을 삭제할까요?';

  @override
  String get deleteConfirmBody => '계정과 동기화된 저장 휴가가 영구적으로 삭제됩니다.';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get authSignIn => '로그인';

  @override
  String get authCreateAccount => '계정 만들기';

  @override
  String get authWelcomeBack => '다시 오신 것을 환영합니다';

  @override
  String get authCreateHeading => 'daysoff 계정 만들기';

  @override
  String get authTagline => '저장한 휴가를 기기 간에 동기화하세요.';

  @override
  String get fieldEmail => '이메일';

  @override
  String get fieldPassword => '비밀번호 (8자 이상)';

  @override
  String get fieldNameOptional => '이름 (선택사항)';

  @override
  String get authToggleToRegister => '처음이신가요? 계정 만들기';

  @override
  String get authToggleToLogin => '계정이 있으신가요? 로그인';

  @override
  String get authErrorCreds => '이메일 또는 비밀번호가 올바르지 않습니다.';

  @override
  String get authErrorRegister => '계정을 만들 수 없습니다. 이미 사용 중인 이메일일 수 있습니다.';

  @override
  String get authErrorValidation => '이메일과 8자 이상의 비밀번호를 입력하세요.';
}
