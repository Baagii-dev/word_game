import 'package:flutter/services.dart';

import 'settings_service.dart';

enum Sfx { tap, hit, invalid, enemyAttack, victory, defeat }

/// Дууны үйлчилгээ.
///
/// Одоогоор үйлдлийн системийн дан дуу + чичиргээ ашиглана (дууны файл
/// шаардахгүй). Жинхэнэ дууны файл гарвал `audioplayers` нэмж зөвхөн
/// `play()`-г өөрчилнө — дуудаж буй код өөрчлөгдөхгүй.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  void play(Sfx sfx) {
    final settings = SettingsService.instance;

    if (settings.soundOn) {
      switch (sfx) {
        case Sfx.tap:
        case Sfx.hit:
        case Sfx.victory:
          SystemSound.play(SystemSoundType.click);
        case Sfx.invalid:
        case Sfx.enemyAttack:
        case Sfx.defeat:
          SystemSound.play(SystemSoundType.alert);
      }
    }

    if (settings.hapticsOn) {
      switch (sfx) {
        case Sfx.tap:
          HapticFeedback.selectionClick();
        case Sfx.hit:
        case Sfx.victory:
          HapticFeedback.mediumImpact();
        case Sfx.invalid:
          HapticFeedback.lightImpact();
        case Sfx.enemyAttack:
        case Sfx.defeat:
          HapticFeedback.heavyImpact();
      }
    }
  }
}
