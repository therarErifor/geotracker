# Geotracker app — gap analysis vs product vision

Source of truth: `Приложение Tropa.md` (product name not final; gradual rename to Geotracker).

This doc tracks **what exists vs what is missing** and the recommended update stages. Update checkmarks as work lands.

Rules / skills / architecture: `.cursor/` (not `.continue/`).

---

## Diff: vision vs current code

| Area | Vision | Current | Status |
|------|--------|---------|--------|
| Product scope | Local GPS tracker, no backend | Local-only; empty `ApiClient` stub | Partial |
| Live map | Current position + follow camera | Map + marker + camera follow + recenter | Partial |
| GPS recording | Location stream → filtered TrackPoints | `TrackRecordingService` + `GpsFilter`; points in `MainState` | Partial |
| Polyline | Live path on map | `PolylineLayer` in `Map` widget | Partial |
| Pause / resume / finish | Real session control | `TrackRecordingService` wired to Cubit | Partial |
| Realtime stats | distance, time, speeds, elevation | `LiveStatsOverlay` (distance, time, current/avg km/h) | Partial |
| Domain models | Track, TrackPoint, Stop, Marker | `Track`, `TrackPoint`, `Stop`, `Marker` + calcs | Partial |
| GPS filtering | accuracy / distance / interval / outliers | `GpsFilter` in domain (+ unit tests) | Partial |
| Stops | auto-detect from speed + duration | `StopDetection` (pause, GPS speed, time gaps) | Done |
| Local persistence | TrackRepository → local DB/files | Drift schema v2 + stops/markers tables | Partial |
| History | track list + rename/delete | `features/history/` list, rename, delete | Partial |
| Details | full track + stats on map | `features/details/` polyline, start/end, stats, Replay | Partial |
| Replay | play/pause/seek/speed/camera | `features/replay/` | Partial |
| Markers / photos | POI + optional photos | User markers on Live/Details/Replay; photos later | Partial |
| Graphs | speed/elevation charts | None | Missing |
| Background tracking | Android/iOS background location | FGS + iOS Always + draft kill recovery | Done |
| GPX | import/export | None (Phase 3); planned as domain ↔ GPX mapper | Missing |
| Architecture | presentation / domain / data | `lib/src/data/` + history/details/replay | Partial |
| Tests | domain unit tests | domain + mapper + stop/interpolation + draft persistence | Partial |

### What already works

- Flutter app shell (`GeotrackerApp`), DI (`injectable` + `get_it`)
- `MainScreen` + Cubit Freezed states (`init` / `loaded` / `error`)
- `GeolocationService`: permissions, last/current position, recording stream (FGS / iOS background)
- `flutter_map` OSM tiles + user heading marker
- Tracking UI buttons wired to real recording session
- Domain: `Track`, `TrackPoint`, `Stop`, `Marker`, `TrackCalculations`, `GpsFilter`, `SessionElapsed` (+ unit tests)
- Live: polyline, stats overlay, camera follow with recenter
- Persistence: Drift SQLite, save from Live, History + Details
- Replay: timeline, speeds 1x–50x, camera follow
- Stops: domain detection on save; markers during recording
- Background: Android FGS notification + iOS Always / `UIBackgroundModes`; draft checkpoint kill recovery
- GPX import/export deferred to Stage 6

---

## Storage decision (Stage 3)

**Choice: SQLite via Drift.**

| Option | Pros | Cons for this app |
|--------|------|-------------------|
| Hive | Tiny API, fast for small blobs | Large tracks = whole list in memory; awkward for GPX round-trips |
| plain sqflite | Native SQLite, efficient | More manual SQL / mapping boilerplate |
| **Drift** | Typed SQLite, streaming queries, good for many `TrackPoint` rows | Codegen once; then stable |

Why Drift:

- Tracks can have thousands of points — row storage is lighter than loading nested Hive objects.
- GPX import/export maps **domain `Track` ↔ GPX file**, not DB schema; storage stays swappable behind `TrackRepository`.
- Settings later can still use a small key-value store if needed; tracks stay in SQLite.

Do **not** add Drift until Stage 3 starts.

---

## Target architecture

```text
presentation (Cubit + screens)
        ↓
domain (Track*, stats, filtering rules, stop detection)
        ↓
services (recording session, geolocation wrapper)
        ↓
data (TrackRepository → LocalTrackDataSource → Drift/SQLite)
```

- No business logic in UI
- Repository abstraction; swappable storage
- DI; testable domain
- Minimal coupling to Flutter plugins
- Platform background code isolated
- Priority: correctness → simplicity → testability → performance → extras

Keep Cubit + Freezed + injectable. Do not introduce BLoC events unless needed.

**Live / History / Details / Replay** feature folders: introduce when each mode is implemented. Do not rename `main` → `live` until that task is requested.

---

## Stack decisions

- Map: **flutter_map** (OSM raster for now; tile URL only in UI/adapter).
- Storage (Stage 3): **Drift (SQLite)**.
- GPX (Stage 6 / Phase 3): domain mapper + dedicated package when needed.
- Offline maps (Phase 4): postponed.
- Charts / photos / Hive: only when their stage starts.

---

## Platform configuration checklist

- [x] iOS `NSLocationWhenInUseUsageDescription` in `ios/Runner/Info.plist`
- [x] Android `ACCESS_BACKGROUND_LOCATION` omitted (FGS + notification used instead)
- [x] Stage 5: Android foreground service (`location`) + notification; iOS `UIBackgroundModes: location` + Always permission
- [ ] Stage 5+: battery/lifecycle / kill recovery on real devices

---

## Update stages

### Stage 0 — Foundation — DONE (2026-09)

- [x] `Track`, `TrackPoint` in `lib/src/domain/`
- [x] Pure functions: distance, duration, avg/max speed (`TrackCalculations`)
- [x] Unit tests for domain math
- [x] Dependencies refreshed in `pubspec.yaml` / lockfile
- [x] Light rename: `TropaApp` → `GeotrackerApp`
- [x] `Stop`, `Marker` — Stage 4

### Stage 1 — GPS pipeline (foreground) — DONE (2026-09)

- [x] Location stream via geolocation service
- [x] Map location → `TrackPoint`
- [x] Basic filtering (min accuracy / distance / interval)
- [x] Recording session: start / pause / resume / stop
- [x] Wire current Live Cubit (`MainCubit`) to real points (replace status-only stubs)
- [x] Do **not** extract `features/live/` yet

### Stage 2 — Map Live MVP — DONE (2026-09)

- [x] Live polyline
- [x] Camera follow while recording (+ recenter after manual pan)
- [x] Realtime stats overlay (distance, time, current/avg speed)
- [x] Reduce Cubit ↔ `MapOptions` coupling where practical

### Stage 3 — Persistence + History + Details — DONE (2026-09)

- [x] Add Drift; `TrackRepository` + local datasource
- [x] Save on finish; list / open / rename / delete
- [x] Details screen: full polyline, start/end, stats
- [ ] GPX import/export/share — Stage 6

### Stage 4 — Replay + stops + markers — DONE (2026-09)

- [x] Replay timeline, speed (1x…50x), camera follow
- [x] Auto stops
- [x] User markers during recording

### Stage 5 — Background + hardening — DONE (2026-09)

- [x] Android foreground service / notification
- [x] iOS background location capabilities
- [x] Recovery after process kill where feasible (Drift draft checkpoint; empty draft → user message)

### Stage 6 — Expansion (Phase 3–4)

- [ ] Graphs; GPX import/export; photos; settings; global stats
- [ ] Optional: offline maps, comparison, heatmap, map styles

---

## Naming (gradual)

| Current | Direction |
|---------|-----------|
| Display name | `Geotracker app` |
| Package | `geotracker` |
| Root widget | `GeotrackerApp` |
| Product doc | `Приложение Tropa.md` (keep until rename pass) |
| Class/file leftovers (`Tropa*`, bike_tracker_*) | Rename when touching those files |

---

## Agent workflow reminder

One stage (or thin vertical slice) per task. After code changes: `flutter analyze` + tests when present.

---

*Living plan — sync with `Приложение Tropa.md` and `.cursor/rules/`.*
