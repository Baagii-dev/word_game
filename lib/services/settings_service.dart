import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Тохиргоо: дуу, чичиргээ, харанхуй горим (dark mode). Төхөөрөмж дээр хадгалагдана.
class SettingsService extends ChangeNotifier {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  bool soundOn = true;
  bool hapticsOn = true;
  bool darkMode = false;
  String nickname = ''; // онлайн тоглоомын ник

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      soundOn = prefs.getBool('soundOn') ?? true;
      hapticsOn = prefs.getBool('hapticsOn') ?? true;
      darkMode = prefs.getBool('darkMode') ?? false;
      nickname = prefs.getString('nickname') ?? '';
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setSound(bool value) async {
    soundOn = value;
    notifyListeners();
    await _save('soundOn', value);
  }

  Future<void> setHaptics(bool value) async {
    hapticsOn = value;
    notifyListeners();
    await _save('hapticsOn', value);
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
    await _save('darkMode', value);
  }

  Future<void> setNickname(String value) async {
    nickname = value.trim();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nickname', nickname);
    } catch (e) {
      debugPrint('Ник хадгалж чадсангүй: $e');
    }
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
