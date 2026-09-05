# Geotracker — тестирование и логирование

Два сценария проверки приложения. Подробности по архитектуре: `docs/mvp_realization.md`.

---

## 1. Тест на эмуляторе

Быстрая проверка UI, записи маршрута, полилинии, статистики, маркеров, Replay и сохранения в History. **Не заменяет** проверку фона, FGS, kill recovery и реального GPS.

### Запуск

```bash
flutter run
```

### Имитация GPS

**Android** — Android Studio → Extended controls (`...`) → **Location**:

- **Routes** или **Load GPX/KML** — маршрут по точкам
- через adb: `adb emu geo fix <longitude> <latitude>`

**iOS** — Xcode → **Features → Location**:

- **Custom GPX File…** — свой маршрут (файл добавить в Runner)
- или встроенные: *City Bicycle Ride*, *City Run*

### Что проверить

1. Старт → запись → пауза → продолжить → финиш → сохранить
2. Маркер на карте
3. History → Details → Replay

### Логи

Смотреть в терминале `flutter run` (те же строки, что пишутся в файл). Дополнительно на Android:

```bash
adb logcat | grep -E "flutter|geotracker|Geolocator"
```

---

## 2. Тест на реальном устройстве с логами в файл

Проверка фоновой записи, уведомления (Android FGS), разрешения «Всегда» (iOS), восстановления черновика после kill, реального GPS на улице. Кабель после установки **не нужен** — логи пишутся в файл на устройстве.

### Сборка и установка

**Android:**

```bash
flutter build apk --release
flutter install
# или скопировать APK на телефон вручную
```

**iOS:**

```bash
flutter build ios --release
open ios/Runner.xcworkspace
```

Xcode → выбрать iPhone → **Run**. Перед первым запуском: **Developer Mode** и доверие сертификату разработчика в настройках iPhone.

> Не останавливайте `flutter run` через `q` / Ctrl+C, если хотите оставить приложение на телефоне — это завершает процесс на устройстве.

### Логирование в файл

`AppLog` (`lib/src/core/app_log.dart`) пишет в:

```text
<Documents>/logs/geotracker.log
```

Формат строки: `[ISO8601] I|W|E сообщение`. Файл дополняется при каждом запуске.

В коде: `AppLog.i(...)`, `AppLog.w(...)`, `AppLog.e(..., error, stackTrace)`.

Логируются старт приложения, init MainCubit, start/pause/resume/finish записи, GPS stream errors, маркеры, сохранение трека, discard пустого черновика.

### Сценарий прогулки

1. Установить release-сборку, отключить кабель
2. Выдать разрешение на геолокацию (**«Всегда»** на iOS для фона)
3. Записать маршрут 5–10 мин: старт → пауза → продолжить → маркер → финиш → сохранить
4. Проверить kill recovery: во время записи принудительно закрыть приложение → открыть снова
5. Забрать лог (см. ниже)

### Как забрать лог-файл

**Из приложения (предпочтительно):** История → иконка «Поделиться» в AppBar → Telegram / почта / Files.

**Android (adb):**

```bash
adb shell run-as com.example.geotracker cat files/logs/geotracker.log > geotracker.log
```

**iOS:** Xcode → **Window → Devices and Simulators** → приложение → **Download Container** → `AppData/Documents/logs/geotracker.log`.

### Что искать в логе

| Сообщение / паттерн | Значение |
|---------------------|----------|
| `GPS stream error` + `WAKE_LOCK` | Нет разрешения в `AndroidManifest.xml` |
| `No active stream to cancel` | Поток GPS не стартовал (часто следствие WAKE_LOCK) |
| `Geolocator` / `PlatformException` | Проблемы с разрешениями или FGS |
| `Draft discarded empty` | Kill до первой GPS-точки |
| Нет строк после `App start` | `AppLog.init` не отработал |

### Что проверить помимо лога

- Уведомление «Идёт запись маршрута» (Android) при свёрнутом приложении
- Трек в History с корректной дистанцией и временем
- Replay воспроизводит маршрут
