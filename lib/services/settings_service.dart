import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Тохиргоо: дуу, чичиргээ, харанхуй горим (dark mode). Төхөөрөмж дээр хадгалагдана.
class SettingsService extends ChangeNotifier {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  bool? _soundOn = true;
  bool? _hapticsOn = true;
  bool? _darkMode = false;

  // Hot Reload үед хуучин singleton объект дээр шинэ талбар null байсан ч алдаа өгөхгүй.
  bool get soundOn => (_soundOn as dynamic) != false;
  set soundOn(bool value) => _soundOn = value;

  bool get hapticsOn => (_hapticsOn as dynamic) != false;
  set hapticsOn(bool value) => _hapticsOn = value;

  bool get darkMode => (_darkMode as dynamic) == true;
  set darkMode(bool value) => _darkMode = value;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundOn = prefs.getBool('soundOn') ?? true;
      _hapticsOn = prefs.getBool('hapticsOn') ?? true;
      _darkMode = prefs.getBool('darkMode') ?? false;
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setSound(bool value) async {
    _soundOn = value;
    notifyListeners();
    await _save('soundOn', value);
  }

  Future<void> setHaptics(bool value) async {
    _hapticsOn = value;
    notifyListeners();
    await _save('hapticsOn', value);
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    await _save('darkMode', value);
  }

  Future<void> _save(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('Тохиргоо хадгалж чадсангүй: $e');
    }
  }
}
