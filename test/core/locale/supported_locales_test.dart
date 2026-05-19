import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/core/locale/supported_locales.dart';

void main() {
  group('SupportedLocales', () {
    test('default is ar-EG', () {
      expect(SupportedLocales.defaultLocale, const Locale('ar', 'EG'));
    });

    test('ships exactly ar-EG and en', () {
      expect(SupportedLocales.all, hasLength(2));
      expect(SupportedLocales.all, contains(const Locale('ar', 'EG')));
      expect(SupportedLocales.all, contains(const Locale('en')));
    });

    test('idFor / fromId round-trip', () {
      for (final l in SupportedLocales.all) {
        expect(SupportedLocales.fromId(SupportedLocales.idFor(l)), l);
      }
    });

    test('idFor produces ar-EG and en', () {
      expect(SupportedLocales.idFor(const Locale('ar', 'EG')), 'ar-EG');
      expect(SupportedLocales.idFor(const Locale('en')), 'en');
    });

    test('fromId falls back to default on unknown id', () {
      expect(SupportedLocales.fromId('fr'), SupportedLocales.defaultLocale);
    });

    test('isRtl is true only for ar', () {
      expect(SupportedLocales.isRtl(const Locale('ar', 'EG')), isTrue);
      expect(SupportedLocales.isRtl(const Locale('en')), isFalse);
    });
  });
}
