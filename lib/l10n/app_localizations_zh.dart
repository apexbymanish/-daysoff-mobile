// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppL10nZh extends AppL10n {
  AppL10nZh([String locale = 'zh']) : super(locale);

  @override
  String get navHolidays => '假日';

  @override
  String get navPlan => '规划';

  @override
  String get navSettings => '设置';

  @override
  String get planTitle => '规划你的一年';

  @override
  String get lengthBuffet => '按时长';

  @override
  String get sandwichDays => '夹心假';

  @override
  String get bestValueFound => '最划算方案';

  @override
  String get monthAll => '全部';

  @override
  String noBreakOptionsInMonth(String month) {
    return '$month没有休假方案。';
  }

  @override
  String noSandwichDaysInMonth(String month) {
    return '$month没有夹心假。';
  }

  @override
  String get noBreaksForBudget =>
      'No breaks fit this budget. Try increasing it.';

  @override
  String get noSandwichDaysThisYear => '今年没有夹心假。';

  @override
  String get sandwichHint => '夹在休息日之间的单个工作日——请一天假，换一个长周末。';

  @override
  String takeDaysOff(int count) {
    return '请 $count 天假';
  }

  @override
  String get free => '免费';

  @override
  String get absorbed => '已包含';

  @override
  String get seeDetails => '查看详情';

  @override
  String get saveAndRemind => '保存 + 提醒';

  @override
  String get saved => '已保存';

  @override
  String get retry => '重试';

  @override
  String get settingsTitle => '设置';

  @override
  String get sectionPreferences => '偏好设置';

  @override
  String get sectionAppearance => '外观';

  @override
  String get sectionCalendar => '日历与提醒';

  @override
  String get sectionAccount => '账户';

  @override
  String get settingCountry => '工作国家/地区';

  @override
  String get settingWeekend => '周末';

  @override
  String get settingPtoBudget => '年假天数';

  @override
  String get settingBreakLength => '假期时长';

  @override
  String get settingTheme => '主题';

  @override
  String get settingLanguage => '语言';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get appleCalendar => 'Apple 日历';

  @override
  String get notConnected => '未连接';

  @override
  String get defaultReminder => '默认提醒';

  @override
  String daysValue(int count) {
    return '$count 天';
  }

  @override
  String daysRange(int min, int max) {
    return '$min–$max 天';
  }

  @override
  String get signInCreateAccount => '登录 / 创建账户';

  @override
  String get syncTagline => '在多个设备间同步你保存的假期';

  @override
  String get logOut => '退出登录';

  @override
  String get deleteAccount => '删除账户';

  @override
  String get syncOn => '已开启同步';

  @override
  String get deleteConfirmTitle => '删除账户？';

  @override
  String get deleteConfirmBody => '这将永久删除你的账户以及已同步的保存假期。';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get authSignIn => '登录';

  @override
  String get authCreateAccount => '创建账户';

  @override
  String get authWelcomeBack => '欢迎回来';

  @override
  String get authCreateHeading => '创建你的 daysoff 账户';

  @override
  String get authTagline => '在多个设备间同步你保存的假期。';

  @override
  String get fieldEmail => '电子邮箱';

  @override
  String get fieldPassword => '密码（8 位及以上）';

  @override
  String get fieldNameOptional => '姓名（可选）';

  @override
  String get authToggleToRegister => '新用户？创建账户';

  @override
  String get authToggleToLogin => '已有账户？登录';

  @override
  String get authErrorCreds => '邮箱或密码无效。';

  @override
  String get authErrorRegister => '无法创建账户。该邮箱可能已被使用。';

  @override
  String get authErrorValidation => '请输入邮箱和至少 8 位的密码。';
}
