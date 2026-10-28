# Үгийн Тулаан — кодын бүтэц

Монгол үг бүтээж дайсныг ялдаг Flutter тоглоом. Энэ баримт нь "юуг хаанаас
нь засах вэ" гэдгийг харуулна.

## Хавтасны зураглал

```
lib/
├── main.dart            Апп эхлэх: толь бичиг, түвшин, хадгалалт, тохиргоо ачаална
├── app.dart             MaterialApp (theme, маршрут)
│
├── core/                Тоглоомын тохиргоо, дизайнгүй зүйлс
│   ├── constants.dart   GameConfig (самбар, хугацаа, HP...), цагаан толгой, эгшиг
│   ├── routes.dart      Нэрлэсэн маршрутууд
│   └── assets.dart      Зургийн замууд (баатрын зураг)
│
├── design/              ★ ДИЗАЙН — бүх харагдах байдал энд
│   ├── theme.dart       Өнгө (AppColors), хэмжээ (AppSizes), хугацаа, ThemeData
│   ├── steppe_background.dart   Тэнгэр, нар, толгод, гэр зурсан дэвсгэр
│   ├── ornament_strip.dart      Угалз хээний тууз
│   └── characters/
│       ├── character_sprite.dart  Дүр + нэр + анимац (найгах, довтлох, цохигдох, үхэх)
│       ├── hero_art.dart          Баатар (кодоор зурсан, эсвэл зураг)
│       └── enemy_art.dart         Дайсан (зураг эсвэл emoji)
│
├── models/              Өгөгдлийн бүтэц (логикгүй)
│   ├── enemy.dart  level.dart  player.dart  letter_tile.dart  player_progress.dart
│
├── logic/               ★ ТОГЛООМЫН ДҮРЭМ — дэлгэцээс хамаарахгүй
│   ├── battle_controller.dart  Тулааны давталт, ээлж, таймер, оноо
│   ├── letter_generator.dart   Үсгийн самбар үүсгэх, нөхөх, санамж олох
│   ├── word_validator.dart     Үг шалгах (урт, давхцал, толь бичиг)
│   └── damage_calculator.dart  Хохирол = онооны нийлбэр × уртын үржвэр × combo
│
├── services/            Гадаад ресурс
│   ├── dictionary_service.dart  words.txt уншиж, үсгийн давтамж/оноо тооцно
│   ├── storage_service.dart     Ахиц (түвшин, од, оноо) — shared_preferences
│   ├── settings_service.dart    Дуу, чичиргээний тохиргоо
│   └── audio_service.dart       Дуу/чичиргээ (одоогоор системийн дуу)
│
├── screens/             Дэлгэцүүд (логик controller-т, энд зөвхөн харуулна)
│   └── splash  home  level_select  battle  result  settings
│
└── widgets/             Дэлгэц дундын жижиг хэсгүүд
    └── game_button  letter_tile_widget  letter_grid  word_bar  hp_bar
        wave_indicator  damage_popup  shake_widget  rules_dialog

assets/data/   words.txt (толь бичиг), levels.json (түвшин, дайсан)
assets/images/characters/   Дүрсийн зураг (сонголттой)
tools/build_words.py        words.txt-ийг mn_MN.dic-ээс дахин үүсгэх
test/                       Тестүүд (доороос харна уу)
```

## Өгөгдөл хэрхэн урсдаг вэ

```
main.dart ─► DictionaryService.load()  words.txt → Set<String> + үсгийн давтамж/оноо
          ─► loadLevels()              levels.json → kLevels
          ─► StorageService.load()     ахиц
          ─► runApp → Splash → Home → LevelSelect → BattleScreen → ResultScreen
                                                      │
                          BattleScreen ◄── ChangeNotifier ── BattleController
                          (харуулна, товч дарахад метод дуудна)   (бүх дүрэм)
```

**Тулааны нэг ээлж** (`BattleController`):
1. Тоглогч үсэг сонгоно → `selectTile` / `deselectTile`
2. "Довтлох" → `attack()`: `WordValidator.check` → `DamageCalculator.calculate`
   → дайсны HP хасна → ашигласан үсгийг хасаад `LetterGenerator.fillBoard`-оор нөхнө
3. Дайсан үхсэн бол дараагийн дайсан (`_onEnemyDefeated`), үгүй бол `_enemyTurn()`
4. Хугацаа дуусах, "Холих" → combo тасарч дайсны ээлж

Дэлгэц анимац/дууг `BattleController`-ийн тоолууруудаар (`hitCount`,
`enemyAttackCount`, `invalidCount`) мэднэ — тоолуур өөрчлөгдөх бүрт нэг анимац.

## Юуг хаана засах вэ

| Хийх зүйл | Засах газар |
|---|---|
| Өнгө, радиус, анимацийн хугацаа | `lib/design/theme.dart` |
| Дэвсгэр (тэнгэр, толгод, гэр), хээ | `lib/design/steppe_background.dart`, `ornament_strip.dart` |
| Баатрын дүр | `lib/design/characters/hero_art.dart` эсвэл `AppAssets.heroImage` |
| Дайсны зураг | `assets/data/levels.json` дахь `"image": "assets/images/characters/xxx.png"` |
| Дүрийн анимац (найгах, довтлох...) | `lib/design/characters/character_sprite.dart` |
| Товч, үсгийн хавтангийн хэлбэр | `lib/widgets/game_button.dart`, `letter_tile_widget.dart` |
| Дэлгэцийн байрлал | `lib/screens/*.dart` |
| Тоглоомын хүндрэл (HP, хугацаа, самбар, санамж) | `lib/core/constants.dart` (`GameConfig`) |
| Дайсан, түвшин нэмэх/өөрчлөх | `assets/data/levels.json` (код засах шаардлагагүй) |
| Хохиролын томьёо, combo | `lib/logic/damage_calculator.dart` |
| Үсгийн самбарын дүрэм (эгшиг %, давхцал) | `GameConfig` + `lib/logic/letter_generator.dart` |
| Толь бичиг | `python3 tools/build_words.py <mn_MN.dic>` (README-г үз) |
| Заавар текст | `lib/widgets/rules_dialog.dart` |

**Дизайн өөрчлөх дүрэм:** өнгө, хэмжээг шууд кодод бичихгүй, `AppColors` /
`AppSizes`-д нэмж тэндээс авна. Тэгвэл дизайныг нэг файлаас солих боломжтой.
Дизайн нь `lib/design/` болон `lib/widgets/`-д; тоглоомын дүрэм
(`lib/logic/`) дизайнаас огт хамаарахгүй тул дизайн засахад дүрэм эвдрэхгүй.

## Тест

```bash
flutter test
```

| Файл | Юуг шалгадаг |
|---|---|
| `word_generation_test.dart` | Самбар: 12 үсэг, эгшиг 5–6, нэг үсэг ≤3, нөхөлт, санамж, толь бичиг |
| `battle_simulation_test.dart` | Автомат тоглогч бүтэн тулаан (бүх түвшин), pause, ялагдал |
| `battle_controller_test.dart` | Combo, санамж, тусгай цохилт, хугацаа |
| `damage_calculator_test.dart`, `word_validator_test.dart`, `letter_generator_test.dart` | Нэгж тестүүд |
| `real_dictionary_test.dart` | Бодит толь бичгийн ачаалал, хурд |
| `*_layout_test.dart` | Жижиг утсан дээр дэлгэц халихгүй эсэх (320×568 хүртэл) |
| `storage_service_test.dart` | Ахиц хадгалалт |

## Багаар ажиллахад

- `git pull` хийсний дараа `flutter pub get` ажиллуулна (шинэ package нэмэгдсэн байж болно).
- `pubspec.lock`, `linux/`, `windows/`, `macos/`-ийн `generated_plugin*` файлууд
  `pub get`-ээр өөрчлөгддөг тул ихэвчлэн conflict гаргадаг — сүүлийн хувилбарыг авч
  `flutter pub get` дахин ажиллуулна.
- Нэг файлыг хоёр хүн зэрэг бүү засаарай; дизайн (`lib/design`, `widgets`) ба
  логик (`lib/logic`) тусдаа тул хуваан ажиллахад хялбар.
