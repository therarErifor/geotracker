import 'package:flutter_test/flutter_test.dart';
import 'package:geotracker/src/data/mappers/track_mapper.dart';
import 'package:geotracker/src/domain/marker.dart';
import 'package:geotracker/src/domain/stop.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:geotracker/src/domain/track_point.dart';

void main() {
  const mapper = TrackMapper();

  group('TrackMapper', () {
    test('round-trips track aggregates through companion fields', () {
      final startedAt = DateTime.utc(2026, 9, 4, 10);
      final finishedAt = startedAt.add(const Duration(minutes: 30));
      final track = Track(
        id: 'track-1',
        name: 'Test track',
        startedAt: startedAt,
        finishedAt: finishedAt,
        duration: const Duration(minutes: 25),
        movingDuration: const Duration(minutes: 25),
        stoppedDuration: Duration.zero,
        distanceMeters: 4200,
        averageSpeedMps: 2.8,
        maxSpeedMps: 5.5,
        elevationGainMeters: 40,
        points: [
          TrackPoint(
            latitude: 55.75,
            longitude: 37.62,
            timestamp: startedAt,
            altitude: 100,
            speed: 2,
            accuracy: 8,
          ),
          TrackPoint(
            latitude: 55.76,
            longitude: 37.63,
            timestamp: finishedAt,
            altitude: 120,
            speed: 3,
            accuracy: 6,
          ),
        ],
      );

      final companion = mapper.trackToCompanion(track);
      expect(companion.id.value, 'track-1');
      expect(companion.name.value, 'Test track');
      expect(companion.durationMs.value, 25 * 60 * 1000);
      expect(companion.distanceMeters.value, 4200);
      expect(companion.elevationGainMeters.value, 40);

      final pointCompanions = mapper.pointsToCompanions(track.id, track.points);
      expect(pointCompanions, hasLength(2));
      expect(pointCompanions[0].orderIndex.value, 0);
      expect(pointCompanions[1].orderIndex.value, 1);
      expect(pointCompanions[0].trackId.value, 'track-1');
      expect(pointCompanions[1].latitude.value, 55.76);
    });

    test('maps stops and markers to companions', () {
      final startedAt = DateTime.utc(2026, 9, 4, 10);
      final track = Track(
        id: 'track-1',
        name: 'Test track',
        startedAt: startedAt,
        points: const [],
        stops: [
          Stop(
            startedAt: startedAt,
            finishedAt: startedAt.add(const Duration(minutes: 2)),
            duration: const Duration(minutes: 2),
            latitude: 55.75,
            longitude: 37.62,
          ),
        ],
        markers: [
          Marker(
            id: 'marker-1',
            latitude: 55.751,
            longitude: 37.621,
            timestamp: startedAt.add(const Duration(minutes: 1)),
            title: 'Lake',
            description: 'Rest stop',
          ),
        ],
      );

      final stopCompanions = mapper.stopsToCompanions(track.id, track.stops);
      expect(stopCompanions, hasLength(1));
      expect(stopCompanions.first.durationMs.value, 2 * 60 * 1000);
      expect(stopCompanions.first.trackId.value, 'track-1');

      final markerCompanions =
          mapper.markersToCompanions(track.id, track.markers);
      expect(markerCompanions, hasLength(1));
      expect(markerCompanions.first.id.value, 'marker-1');
      expect(markerCompanions.first.title.value, 'Lake');
    });
  });
}
