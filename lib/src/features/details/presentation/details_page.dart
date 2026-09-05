import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geotracker/src/dependencies_config.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:geotracker/src/domain/track_point.dart';
import 'package:geotracker/src/features/replay/presentation/replay_page.dart';
import 'package:geotracker/src/ui/formatters/track_formatters.dart';
import 'package:geotracker/src/ui/widgets/widgets_export.dart';
import 'package:latlong2/latlong.dart';

import 'details_cubit.dart';
import 'details_state.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key, required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => container<DetailsCubit>()..load(trackId),
      child: _DetailsView(trackId: trackId),
    );
  }
}

class _DetailsView extends StatefulWidget {
  const _DetailsView({required this.trackId});

  final String trackId;

  @override
  State<_DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<_DetailsView> {
  final MapController _mapController = MapController();
  bool _didFitBounds = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<DetailsCubit, DetailsState>(
          builder: (context, state) {
            return Text(
              state.maybeWhen(
                loaded: (track) => track.name,
                orElse: () => 'Маршрут',
              ),
            );
          },
        ),
      ),
      body: BlocConsumer<DetailsCubit, DetailsState>(
        listener: (context, state) {
          state.maybeWhen(
            loaded: (track) {
              _didFitBounds = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _fitTrack(track.points);
              });
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const InitializationWidget(),
            loading: () => const InitializationWidget(),
            error: (error) => LoadingErrorWidget(
              errorText: error.toString(),
              buttonText: 'Назад',
              callback: () => Navigator.of(context).pop(),
            ),
            loaded: (track) => _buildLoaded(context, track),
          );
        },
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, Track track) {
    if (track.points.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'В этом маршруте нет точек. Его можно удалить.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _deleteTrack(context),
              child: const Text('Удалить маршрут'),
            ),
          ],
        ),
      );
    }

    final center = LatLng(
      track.points.first.latitude,
      track.points.first.longitude,
    );

    return Column(
      children: [
        Expanded(
          child: Map(
            controller: _mapController,
            initialCenter: center,
            initialZoom: 14,
            recordingPoints: track.points,
            stops: track.stops,
            trackMarkers: track.markers,
            showStartEndMarkers: true,
            onMapReady: () => _fitTrack(track.points),
          ),
        ),
        _TrackStatsPanel(
          track: track,
          onReplay: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ReplayPage(trackId: widget.trackId),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _deleteTrack(BuildContext context) async {
    await context.read<DetailsCubit>().delete(widget.trackId);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void _fitTrack(List<TrackPoint> points) {
    if (_didFitBounds || points.isEmpty) {
      return;
    }
    if (points.length == 1) {
      _mapController.move(
        LatLng(points.first.latitude, points.first.longitude),
        16,
      );
      _didFitBounds = true;
      return;
    }

    final latitudes = points.map((p) => p.latitude);
    final longitudes = points.map((p) => p.longitude);
    final bounds = LatLngBounds(
      LatLng(
        latitudes.reduce((a, b) => a < b ? a : b),
        longitudes.reduce((a, b) => a < b ? a : b),
      ),
      LatLng(
        latitudes.reduce((a, b) => a > b ? a : b),
        longitudes.reduce((a, b) => a > b ? a : b),
      ),
    );
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
    );
    _didFitBounds = true;
  }
}

class _TrackStatsPanel extends StatelessWidget {
  const _TrackStatsPanel({required this.track, required this.onReplay});

  final Track track;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final averageKilometersPerHour = TrackFormatters.metersPerSecondToKilometersPerHour(track.averageSpeedMps);
    final maxKilometersPerHour = TrackFormatters.metersPerSecondToKilometersPerHour(track.maxSpeedMps);

    return Material(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Статистика', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _Stat(
                  label: 'Дистанция',
                  value: TrackFormatters.formatDistanceKm(track.distanceMeters),
                ),
                _Stat(
                  label: 'Время',
                  value: TrackFormatters.formatDuration(track.duration),
                ),
                _Stat(
                  label: 'В движении',
                  value: TrackFormatters.formatDuration(track.movingDuration),
                ),
                _Stat(
                  label: 'Остановки',
                  value: TrackFormatters.formatDuration(
                    track.stoppedDuration,
                  ),
                ),
                _Stat(
                  label: 'Остановок',
                  value: '${track.stops.length}',
                ),
                _Stat(
                  label: 'Средняя',
                  value: TrackFormatters.formatSpeedKmh(averageKilometersPerHour),
                ),
                _Stat(
                  label: 'Макс.',
                  value: TrackFormatters.formatSpeedKmh(maxKilometersPerHour),
                ),
                _Stat(
                  label: 'Набор высоты',
                  value: '${track.elevationGainMeters.round()} м',
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onReplay,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Replay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
