// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppL10nVi extends AppL10n {
  AppL10nVi([String locale = 'vi']) : super(locale);

  @override
  String get navHolidays => 'Ngày lễ';

  @override
  String get navPlan => 'Lập kế hoạch';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get planTitle => 'Lên kế hoạch cho năm';

  @override
  String get lengthBuffet => 'Theo độ dài';

  @override
  String get sandwichDays => 'Ngày kẹp';

  @override
  String get bestValueFound => 'Lựa chọn tối ưu nhất';

  @override
  String get monthAll => 'Tất cả';

  @override
  String noBreakOptionsInMonth(String month) {
    return 'Không có lựa chọn nghỉ trong $month.';
  }

  @override
  String noSandwichDaysInMonth(String month) {
    return 'Không có ngày kẹp trong $month.';
  }

  @override
  String get noBreaksForBudget =>
      'No breaks fit this budget. Try increasing it.';

  @override
  String get noSandwichDaysThisYear => 'Không có ngày kẹp trong năm nay.';

  @override
  String get sandwichHint =>
      'Ngày làm việc lẻ nằm giữa các ngày nghỉ — nghỉ một ngày, được cả kỳ nghỉ dài.';

  @override
  String takeDaysOff(int count) {
    return 'Nghỉ $count ngày';
  }

  @override
  String get free => 'Miễn phí';

  @override
  String get absorbed => 'Đã gộp';

  @override
  String get seeDetails => 'Xem chi tiết';

  @override
  String get saveAndRemind => 'Lưu + nhắc';

  @override
  String get saved => 'Đã lưu';

  @override
  String get retry => 'Thử lại';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get sectionPreferences => 'Tùy chọn';

  @override
  String get sectionAppearance => 'Giao diện';

  @override
  String get sectionCalendar => 'Lịch và nhắc nhở';

  @override
  String get sectionAccount => 'Tài khoản';

  @override
  String get settingCountry => 'Quốc gia làm việc';

  @override
  String get settingWeekend => 'Cuối tuần';

  @override
  String get settingPtoBudget => 'Số ngày phép';

  @override
  String get settingBreakLength => 'Độ dài kỳ nghỉ';

  @override
  String get settingTheme => 'Giao diện';

  @override
  String get settingLanguage => 'Ngôn ngữ';

  @override
  String get themeSystem => 'Hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get languageSystem => 'Mặc định hệ thống';

  @override
  String get appleCalendar => 'Lịch Apple';

  @override
  String get notConnected => 'Chưa kết nối';

  @override
  String get defaultReminder => 'Nhắc nhở mặc định';

  @override
  String daysValue(int count) {
    return '$count ngày';
  }

  @override
  String daysRange(int min, int max) {
    return '$min–$max ngày';
  }

  @override
  String get signInCreateAccount => 'Đăng nhập / Tạo tài khoản';

  @override
  String get syncTagline => 'Đồng bộ các kỳ nghỉ đã lưu trên mọi thiết bị';

  @override
  String get logOut => 'Đăng xuất';

  @override
  String get deleteAccount => 'Xóa tài khoản';

  @override
  String get syncOn => 'đã bật đồng bộ';

  @override
  String get deleteConfirmTitle => 'Xóa tài khoản?';

  @override
  String get deleteConfirmBody =>
      'Thao tác này xóa vĩnh viễn tài khoản và các kỳ nghỉ đã lưu được đồng bộ.';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get authSignIn => 'Đăng nhập';

  @override
  String get authCreateAccount => 'Tạo tài khoản';

  @override
  String get authWelcomeBack => 'Chào mừng trở lại';

  @override
  String get authCreateHeading => 'Tạo tài khoản daysoff của bạn';

  @override
  String get authTagline => 'Đồng bộ các kỳ nghỉ đã lưu trên mọi thiết bị.';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Mật khẩu (8+ ký tự)';

  @override
  String get fieldNameOptional => 'Tên (tùy chọn)';

  @override
  String get authToggleToRegister => 'Lần đầu? Tạo tài khoản';

  @override
  String get authToggleToLogin => 'Đã có tài khoản? Đăng nhập';

  @override
  String get authErrorCreds => 'Email hoặc mật khẩu không hợp lệ.';

  @override
  String get authErrorRegister =>
      'Không thể tạo tài khoản. Email có thể đã được sử dụng.';

  @override
  String get authErrorValidation =>
      'Nhập email và mật khẩu từ 8 ký tự trở lên.';
}
