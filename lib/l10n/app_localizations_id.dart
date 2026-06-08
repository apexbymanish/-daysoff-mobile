// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppL10nId extends AppL10n {
  AppL10nId([String locale = 'id']) : super(locale);

  @override
  String get navHolidays => 'Hari Libur';

  @override
  String get navPlan => 'Rencana';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get planTitle => 'Rencanakan tahunmu';

  @override
  String get lengthBuffet => 'Berdasarkan durasi';

  @override
  String get sandwichDays => 'Hari kejepit';

  @override
  String get bestValueFound => 'Pilihan paling hemat';

  @override
  String get monthAll => 'Semua';

  @override
  String noBreakOptionsInMonth(String month) {
    return 'Tidak ada opsi libur di $month.';
  }

  @override
  String noSandwichDaysInMonth(String month) {
    return 'Tidak ada hari kejepit di $month.';
  }

  @override
  String get noBreaksForBudget =>
      'No breaks fit this budget. Try increasing it.';

  @override
  String get noSandwichDaysThisYear => 'Tidak ada hari kejepit tahun ini.';

  @override
  String get sandwichHint =>
      'Hari kerja tunggal yang terapit hari libur — ambil satu, dapat akhir pekan panjang.';

  @override
  String takeDaysOff(int count) {
    return 'Ambil cuti $count hari';
  }

  @override
  String get free => 'Gratis';

  @override
  String get absorbed => 'Termasuk';

  @override
  String get seeDetails => 'Lihat detail';

  @override
  String get saveAndRemind => 'Simpan + ingatkan';

  @override
  String get saved => 'Tersimpan';

  @override
  String get retry => 'Coba lagi';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get sectionPreferences => 'Preferensi';

  @override
  String get sectionAppearance => 'Tampilan';

  @override
  String get sectionCalendar => 'Kalender & pengingat';

  @override
  String get sectionAccount => 'Akun';

  @override
  String get settingCountry => 'Negara tempat kerja';

  @override
  String get settingWeekend => 'Akhir pekan';

  @override
  String get settingPtoBudget => 'Jatah cuti';

  @override
  String get settingBreakLength => 'Durasi libur';

  @override
  String get settingTheme => 'Tema';

  @override
  String get settingLanguage => 'Bahasa';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get languageSystem => 'Bawaan sistem';

  @override
  String get appleCalendar => 'Kalender Apple';

  @override
  String get notConnected => 'Tidak terhubung';

  @override
  String get defaultReminder => 'Pengingat default';

  @override
  String daysValue(int count) {
    return '$count hari';
  }

  @override
  String daysRange(int min, int max) {
    return '$min–$max hari';
  }

  @override
  String get signInCreateAccount => 'Masuk / Buat akun';

  @override
  String get syncTagline => 'Sinkronkan libur tersimpan di semua perangkat';

  @override
  String get logOut => 'Keluar';

  @override
  String get deleteAccount => 'Hapus akun';

  @override
  String get syncOn => 'sinkron aktif';

  @override
  String get deleteConfirmTitle => 'Hapus akun?';

  @override
  String get deleteConfirmBody =>
      'Ini menghapus permanen akunmu dan libur tersimpan yang disinkronkan.';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get authSignIn => 'Masuk';

  @override
  String get authCreateAccount => 'Buat akun';

  @override
  String get authWelcomeBack => 'Selamat datang kembali';

  @override
  String get authCreateHeading => 'Buat akun daysoff kamu';

  @override
  String get authTagline => 'Sinkronkan libur tersimpan di semua perangkat.';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Kata sandi (8+ karakter)';

  @override
  String get fieldNameOptional => 'Nama (opsional)';

  @override
  String get authToggleToRegister => 'Baru di sini? Buat akun';

  @override
  String get authToggleToLogin => 'Sudah punya akun? Masuk';

  @override
  String get authErrorCreds => 'Email atau kata sandi tidak valid.';

  @override
  String get authErrorRegister =>
      'Tidak dapat membuat akun. Email mungkin sudah digunakan.';

  @override
  String get authErrorValidation =>
      'Masukkan email dan kata sandi minimal 8 karakter.';
}
