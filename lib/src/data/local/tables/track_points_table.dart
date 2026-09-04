import 'package:drift/drift.dart';

import 'tracks_table.dart';

@DataClassName('TrackPointRow')
class TrackPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get trackId =>
      text().references(Tracks, #id, onDelete: KeyAction.cascade)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real().nullable()();
  RealColumn get speed => real().nullable()();
  RealColumn get accuracy => real().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get orderIndex => integer()();
}
