import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum ThemeModePreference { light, dark }

enum AppLocalePreference { english, khmer }

class SettingsProvider extends ChangeNotifier {
  static const _themeKey = 'settings_theme';
  static const _fontScaleKey = 'settings_font_scale';
  static const _localeKey = 'settings_locale';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ThemeModePreference _themeMode = ThemeModePreference.light;
  double _fontScale = 1.0;
  AppLocalePreference _locale = AppLocalePreference.english;

  ThemeModePreference get themeMode => _themeMode;
  double get fontScale => _fontScale;
  AppLocalePreference get localePreference => _locale;
  bool get isDark => _themeMode == ThemeModePreference.dark;
  Locale get locale =>
      _locale == AppLocalePreference.english ? const Locale('en') : const Locale('km');

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final theme = await _storage.read(key: _themeKey);
      if (theme == 'dark') _themeMode = ThemeModePreference.dark;

      final scale = await _storage.read(key: _fontScaleKey);
      if (scale != null) _fontScale = double.tryParse(scale) ?? 1.0;

      final locale = await _storage.read(key: _localeKey);
      if (locale == 'km') _locale = AppLocalePreference.khmer;

      notifyListeners();
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeModePreference mode) async {
    _themeMode = mode;
    await _storage.write(
        key: _themeKey, value: mode == ThemeModePreference.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setThemeMode(
      _themeMode == ThemeModePreference.dark
          ? ThemeModePreference.light
          : ThemeModePreference.dark,
    );
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    await _storage.write(key: _fontScaleKey, value: scale.toStringAsFixed(2));
    notifyListeners();
  }

  Future<void> setLocale(AppLocalePreference locale) async {
    _locale = locale;
    await _storage.write(
        key: _localeKey, value: locale == AppLocalePreference.khmer ? 'km' : 'en');
    notifyListeners();
  }
}
