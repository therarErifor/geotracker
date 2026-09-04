import 'package:drift/drift.dart';

import 'tracks_table.dart';

@DataClassName('StopRow')
class TrackStops extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get trackId =>
      text().references(Tracks, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime()();
  IntColumn get durationMs => integer()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
}
