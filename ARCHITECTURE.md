# Үлгэрийн Баатар — кодын бүтэц

Монгол ардын үлгэрээр аялж, үг бүтээн дайсныг ялдаг Flutter тоглоом. Энэ
баримт нь "юуг хаанаас нь засах вэ" гэдгийг харуулна.

## Хавтасны зураглал

```
lib/
├── main.dart            Апп эхлэх: толь бичиг, үлгэрүүд, хадгалалт, тохиргоо ачаална
├── app.dart             MaterialApp (theme, маршрут)
│
├── core/
│   ├── constants.dart   kAppTitle, GameConfig (самбар, хугацаа, тусгай үсэг...), цагаан толгой
│   ├── routes.dart      Нэрлэсэн маршрутууд (splash, home, chapters, history, settings)
│   └── assets.dart      Баатрын зургийн зам
│
├── design/              ★ ДИЗАЙН — бүх харагдах байдал энд
│   ├── theme.dart       Өнгө (AppColors), хэмжээ (AppSizes), хугацаа, ThemeData
│   ├── scene_background.dart  Үлгэрийн орчин: тал, говь, өвлийн ой, уул, агуй (кодоор зурсан)
│   ├── parchment.dart   Илгэн цаасан хуудас (ParchmentCard), үлгэрийн текстийн хэв маяг
│   ├── weather.dart     Замын хуудсан дээрх бороо, цас, элс, салхи, гал оч
│   ├── glass.dart       Тунгалаг самбар, товч, бараан градиент
│   └── characters/      Баатар, дайсны дүрс (кодоор зурсан эсвэл PNG) + анимац
│
├── models/              Өгөгдлийн бүтэц
│   ├── chapter.dart     Үлгэр (эхлэл, зам, төгсгөл, сургамж, орчин, дайснууд) + stories.json ачаалах
│   ├── tale_path.dart   Замын хуудас (PathSegment) ба саад (PathObstacle), `[үг]` тэмдэглэгээ
│   ├── enemy.dart       Дайсан, төрөл (EnemyKind), тусгай чадвар (EnemySpecial)
│   ├── letter_tile.dart Үсгийн хавтан (алтан / эдгээх / хараагдсан)
│   ├── player.dart  player_progress.dart
│
├── logic/               ★ ТОГЛООМЫН ДҮРЭМ — дэлгэцээс хамаарахгүй
│   ├── battle_controller.dart  Тулааны давталт, ээлж, таймер, тусгай чадвар, оноо
│   ├── path_controller.dart    Замын давталт: алхах, саадтай тулах, үг шалгах, зүрх, оноо
│   ├── letter_generator.dart   Самбар үүсгэх/нөхөх, тусгай үсэг, санамж олох
│   ├── word_validator.dart     Үг шалгах (урт, давхцал, толь бичиг)
│   └── damage_calculator.dart  Хохирол = онооны нийлбэр × уртын үржвэр × combo
│
├── services/            dictionary, storage (ахиц), settings, audio
│
├── screens/
│   ├── tale_flow.dart          ★ Үлгэрийн урсгал: эхлэл → тулаан → төгсгөл → үр дүн
│   ├── story_screen.dart       Үлгэрийн хуудас (үсэг үсгээр бичигдэнэ)
│   ├── path_screen.dart        Үлгэрийн зам (баатар текст дээгүүр алхаж саад давна)
│   ├── chapter_select_screen.dart  Үлгэрийн ном (бүлэг сонгох)
│   └── splash  home  battle  result  history  settings
│
└── widgets/             game_button  letter_tile_widget  letter_grid  word_bar
                         hp_bar  damage_popup  shake_widget  rules_dialog

assets/data/   words.txt (толь бичиг), stories.json (үлгэр, дайснууд)
```

## Урсгал

```
main.dart ─► DictionaryService.load()  words.txt → Set<String> + үсгийн давтамж/оноо
          ─► loadChapters()            stories.json → kChapters
          ─► runApp → Splash → Home → Үлгэрийн ном
                                          │ TaleFlow.start
                                          ▼
              StoryScreen (эхлэл) ─► PathScreen (зам) ─► BattleScreen ─► TaleFlow.finishBattle
                                                      │ (ахицыг шууд хадгална)
                                     ялсан: StoryScreen (төгсгөл + сургамж) ─► ResultScreen
                                     ялагдсан: ResultScreen
```

**Тулааны нэг ээлж** (`BattleController`):
1. Тоглогч үсэг сонгоно (`selectTile`; хараагдсан үсэг сонгогдохгүй), `undo` сүүлийнхийг буцаана
2. `attack()`: үг шалгах → хохирол (алтан үсэг 3×) → эдгээх үсэг амь нэмнэ → самбар нөхнө
3. Дайсан үхсэн бол дараагийн дайсан (түүний `intro` үг ярианы бөмбөлөгт гарна), үгүй бол дайсны ээлж
4. Дайсны ээлж: `specialEvery` ээлж тутамд `special` (strike 2× / curse 2 үсэг түгжих / heal 25%)

## Юуг хаана засах вэ

| Хийх зүйл | Засах газар |
|---|---|
| Шинэ үлгэр, текст, дайсан, хүндрэл | `assets/data/stories.json` (код засах шаардлагагүй) |
| Үлгэрийн орчин (дэвсгэр) | `lib/design/scene_background.dart` (`Scene` enum — `chapter.dart`) |
| Шинэ дайсны дүрс | `EnemyKind`-д нэмээд `enemy_art.dart`-д зурах, эсвэл JSON-д `"image"` |
| Өнгө, радиус, анимацийн хугацаа | `lib/design/theme.dart` |
| Тусгай үсгийн магадлал, хараал, эдгэрэлт | `lib/core/constants.dart` (`GameConfig`) |
| Хохиролын томьёо, combo | `lib/logic/damage_calculator.dart` |
| Заавар текст | `lib/widgets/rules_dialog.dart` |

### stories.json-ийн бүтэц

```json
{
  "id": 1, "title": "...", "subtitle": "...",
  "scene": "steppe | desert | winter | mountain | cave",
  "playerHp": 30,
  "intro": ["хуудас 1", "хуудас 2"], "outro": ["..."], "moral": "...",
  "path": [
    { "text": "Хадыг [алх]аар бутлана.",
      "obstacles": [ { "name": "Өндөр хад", "word": "алх", "at": 0.5, "emoji": "🪨" } ] }
  ],
  "enemies": [
    { "name": "...", "kind": "mouse", "maxHp": 12, "attack": 2,
      "special": "strike | curse | heal", "specialEvery": 3, "intro": "..." }
  ]
}
```

## Тест

```bash
flutter test
```

| Файл | Юуг шалгадаг |
|---|---|
| `battle_simulation_test.dart` | Bot бүх үлгэрийг бодит толь бичгээр тоглоно; үлгэр бүр давагдах боломжтой эсэх |
| `path_controller_test.dart` | Зам: алхах, саадтай тулах, зөв/буруу үг, зүрх алдах, дуусах; stories.json-ийн замын үгс толь бичигт байгаа эсэх |
| `battle_controller_test.dart` | Combo, санамж, тусгай чадвар (хүчтэй цохилт, хараал, эдгэрэлт), алтан/эдгээх үсэг |
| `word_generation_test.dart` | Самбар: 12 үсэг, эгшиг, давхцал, нөхөлт, санамж |
| `battle_screen_layout_test.dart`, `screens_layout_test.dart` | Жижиг утсан дээр (320×568 хүртэл) халихгүй; үлгэрийн хуудасны урсгал |
| `storage_service_test.dart` | Ахиц хадгалалт, ахиц арилгах |
| `integration_test/` | Төхөөрөмж дээр бүх үлгэрийг дуустал / ялагдтал тоглох |

## Багаар ажиллахад

- `git pull` хийсний дараа `flutter pub get` ажиллуулна.
- Дизайн (`lib/design`, `widgets`) ба логик (`lib/logic`) тусдаа тул хуваан ажиллахад хялбар.
- Үлгэрийн текст засах хүн зөвхөн `stories.json`-тэй ажиллана.
