// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ألعاب الأطفال';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsForGrownUps => 'للكبار';

  @override
  String parentGatePrompt(int a, int b) {
    return '$a + $b = ؟';
  }

  @override
  String get parentGateHelp => 'اضغط على الإجابة';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageArabic => 'العربية المصرية';

  @override
  String get settingsLanguageEnglish => 'إنجليزي';

  @override
  String get settingsSound => 'الصوت';

  @override
  String get settingsSoundOn => 'مفعل';

  @override
  String get settingsSoundOff => 'مغلق';

  @override
  String get settingsGames => 'الألعاب';

  @override
  String get settingsGameZoo => 'حديقة الحيوان';

  @override
  String get settingsGameBubblePop => 'الفقاعات';

  @override
  String get settingsGameShapeSorter => 'الأشكال';

  @override
  String get settingsGameFingerPaint => 'الرسم';

  @override
  String get settingsGameDriveVehicle => 'العربية';

  @override
  String get settingsAbout => 'عن التطبيق';

  @override
  String settingsVersion(String version) {
    return 'النسخة $version';
  }

  @override
  String get settingsSupportEmail => 'الدعم';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsTerms => 'الشروط';

  @override
  String get placeholderGameMessage => 'اللعبة دي هتيجي قريب';
}
