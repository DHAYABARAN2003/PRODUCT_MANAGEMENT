import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:product_management_app/core/constants/app_constants.dart';
import 'package:product_management_app/services/local_storage/local_storage_service.dart';

/// Notifier managing theme mode with SharedPreferences persistence.
///
/// Supports three modes: system (auto-detect), light, and dark.
/// Defaults to [ThemeMode.system] when no preference is saved.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final themeString = _prefs.getString(AppConstants.themeModeKey);
    if (themeString != null) {
      switch (themeString) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        default:
          state = ThemeMode.system;
      }
    }
    // If null, remain ThemeMode.system (auto-detect)
  }

  /// Set a specific theme mode and persist.
  void setThemeMode(ThemeMode mode) {
    state = mode;
    _prefs.setString(AppConstants.themeModeKey, mode.name);
  }

  /// Legacy toggle: cycles system → light → dark → system.
  void toggleTheme() {
    switch (state) {
      case ThemeMode.system:
        setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setThemeMode(ThemeMode.system);
        break;
    }
  }

  bool get isDarkMode => state == ThemeMode.dark;
}

/// Provider for [ThemeNotifier].
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});
