// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Toddler Games';

  @override
  String get homeTitle => 'Home';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsForGrownUps => 'For Grown-Ups';

  @override
  String parentGatePrompt(int a, int b) {
    return 'What is $a + $b = ?';
  }

  @override
  String get parentGateHelp => 'Tap the answer';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageArabic => 'Egyptian Arabic';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsSoundOn => 'On';

  @override
  String get settingsSoundOff => 'Off';

  @override
  String get settingsGames => 'Games';

  @override
  String get settingsGameZoo => 'Zoo';

  @override
  String get settingsGameBubblePop => 'Bubble Pop';

  @override
  String get settingsGameShapeSorter => 'Shape Sorter';

  @override
  String get settingsGameFingerPaint => 'Finger Paint';

  @override
  String get settingsGameDriveVehicle => 'Drive';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsSupportEmail => 'Support';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTerms => 'Terms';

  @override
  String get placeholderGameMessage => 'This game is coming soon.';
}
