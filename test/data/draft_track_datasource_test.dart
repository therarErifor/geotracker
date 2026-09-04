import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geotracker/src/data/datasources/local_track_datasource.dart';
import 'package:geotracker/src/data/local/app_database.dart';
import 'package:geotracker/src/data/mappers/track_mapper.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:geotracker/src/domain/track_point.dart';

void main() {
  late AppDatabase db;
  late LocalTrackDataSource dataSource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = LocalTrackDataSource(db, const TrackMapper());
  });

  tearDown(() async {
    await db.close();
  });

  test('drafts are hidden from summaries and empty draft can be discarded',
      () async {
    final startedAt = DateTime.utc(2026, 9, 4, 12);
    await dataSource.createDraft(
      id: 'draft-1',
      name: 'Draft',
      startedAt: startedAt,
      recordingStatus: 'recording',
    );

    expect(await dataSource.getTrackSummaries(), isEmpty);

    final draft = await dataSource.getActiveDraft();
    expect(draft, isNotNull);
    expect(draft!.track.points, isEmpty);

    await dataSource.discardDraft('draft-1');
    expect(await dataSource.getActiveDraft(), isNull);
  });

  test('append points makes draft salvageable and finalize completes track',
      () async {
    final startedAt = DateTime.utc(2026, 9, 4, 12);
    final point = TrackPoint(
      latitude: 55.75,
      longitude: 37.62,
      timestamp: startedAt,
    );
    await dataSource.createDraft(
      id: 'draft-2',
      name: 'Draft',
      startedAt: startedAt,
      recordingStatus: 'recording',
    );

    await dataSource.appendPoints(
      trackId: 'draft-2',
      startOrderIndex: 0,
      points: [point],
    );

    final draft = await dataSource.getActiveDraft();
    expect(draft!.track.points, hasLength(1));

    final finishedAt = startedAt.add(const Duration(minutes: 5));
    await dataSource.finalizeTrack(
      Track(
        id: 'draft-2',
        name: 'Saved track',
        startedAt: startedAt,
        finishedAt: finishedAt,
        duration: const Duration(minutes: 5),
        distanceMeters: 100,
        points: [point],
      ),
    );

    expect(await dataSource.getActiveDraft(), isNull);
    final summaries = await dataSource.getTrackSummaries();
    expect(summaries, hasLength(1));
    expect(summaries.first.id, 'draft-2');
    expect(summaries.first.finishedAt, isNotNull);
  });
}
