# Geotracker app

A local GPS route tracker built with Flutter. Record your journeys on a live map,
keep everything on the device, review detailed stats and replay your routes later —
no backend, no accounts, no cloud sync.

## Product idea

- **Live** — record the current track on the map
- **History** — browse saved tracks
- **Details** — full track view with stats
- **Replay** — interactive playback of a recorded route

Project documentation:

- `Приложение Tropa.md` — product vision (source of truth)
- `docs/mvp_realization.md` — stage plan and gap analysis vs the vision
- `.continue/rules/` — architecture and Dart style conventions

## Tech stack

- Flutter / Dart
- State: Cubit + Freezed
- DI: injectable + get_it
- Maps: flutter_map with OpenStreetMap raster tiles
- Location: geolocator

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

iOS location requires `NSLocationWhenInUseUsageDescription` (already configured in
`ios/Runner/Info.plist`). Background tracking is planned for a later MVP stage.
