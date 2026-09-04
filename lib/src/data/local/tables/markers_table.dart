import 'package:drift/drift.dart';

import 'tracks_table.dart';

@DataClassName('MarkerRow')
class TrackMarkers extends Table {
  TextColumn get id => text()();
  TextColumn get trackId =>
      text().references(Tracks, #id, onDelete: KeyAction.cascade)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get title => text()();
  TextColumn get description => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
