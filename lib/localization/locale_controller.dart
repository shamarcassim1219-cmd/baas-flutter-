import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

/// Holds the current language and notifies every listening screen
/// to rebuild when it changes. Simpler than the customer app's
/// version - a Baas account is always Sri Lankan, so there's no
/// "force English for international accounts" lock to worry about,
/// just a plain persisted preference.
class LocaleController extends ChangeNotifier {
  static const _prefsKey = 'mybaas_baas_lang';

  String _langCode = 'en';
  bool _hasSelected = false;

  String get langCode => _langCode;

  /// False only before the language screen has ever been completed
  /// once - used by _StartupGate to decide whether a brand-new
  /// install should see the language picker before login.
  bool get hasSelected => _hasSelected;

  String t(String key) => AppLocalizations.t(key, _langCode);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    _langCode = stored ?? 'en';
    _hasSelected = stored != null;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _langCode = code;
    _hasSelected = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
  }
}
