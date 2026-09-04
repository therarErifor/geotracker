import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/markers_table.dart';
import 'tables/stops_table.dart';
import 'tables/track_points_table.dart';
import 'tables/tracks_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Tracks, TrackPoints, TrackStops, TrackMarkers])
@LazySingleton()
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(trackStops);
            await m.createTable(trackMarkers);
          }
          if (from < 3) {
            await m.addColumn(tracks, tracks.recordingStatus);
            await m.addColumn(tracks, tracks.pauseIntervalsJson);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'geotracker.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
