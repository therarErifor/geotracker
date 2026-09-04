import 'package:drift/drift.dart';

@DataClassName('TrackRow')
class Tracks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get movingDurationMs => integer().withDefault(const Constant(0))();
  IntColumn get stoppedDurationMs => integer().withDefault(const Constant(0))();
  RealColumn get distanceMeters => real().withDefault(const Constant(0))();
  RealColumn get averageSpeedMps => real().withDefault(const Constant(0))();
  RealColumn get maxSpeedMps => real().withDefault(const Constant(0))();
  RealColumn get elevationGainMeters => real().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
