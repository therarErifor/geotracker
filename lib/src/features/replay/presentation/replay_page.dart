import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geotracker/src/dependencies_config.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:geotracker/src/domain/track_calculations.dart';
import 'package:geotracker/src/domain/track_interpolation.dart';
import 'package:geotracker/src/ui/formatters/track_formatters.dart';
import 'package:geotracker/src/ui/widgets/widgets_export.dart';
import 'package:latlong2/latlong.dart';

import 'replay_cubit.dart';
import 'replay_state.dart';

class ReplayPage extends StatelessWidget {
  const ReplayPage({super.key, required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => container<ReplayCubit>()..load(trackId),
      child: const _ReplayView(),
    );
  }
}

class _ReplayView extends StatelessWidget {
  const _ReplayView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ReplayCubit, ReplayState>(
          builder: (context, state) {
            return Text(
              state.maybeWhen(
                loaded: (track, playbackTime, speed, isPlaying, showRecenter) =>
                    track.name,
                orElse: () => 'Replay',
              ),
            );
          },
        ),
      ),
      body: BlocBuilder<ReplayCubit, ReplayState>(
        builder: (context, state) {
          return state.when(
            initial: () => const InitializationWidget(),
            loading: () => const InitializationWidget(),
            error: (error) => LoadingErrorWidget(
              errorText: error.toString(),
              buttonText: 'Назад',
              callback: () => Navigator.of(context).pop(),
            ),
            loaded: (
              track,
              playbackTime,
              speed,
              isPlaying,
              showRecenterButton,
            ) =>
                _ReplayLoaded(
                  track: track,
                  playbackTime: playbackTime,
                  speed: speed,
                  isPlaying: isPlaying,
                  showRecenterButton: showRecenterButton,
                ),
          );
        },
      ),
    );
  }
}

class _ReplayLoaded extends StatelessWidget {
  const _ReplayLoaded({
    required this.track,
    required this.playbackTime,
    required this.speed,
    required this.isPlaying,
    required this.showRecenterButton,
  });

  final Track track;
  final Duration playbackTime;
  final double speed;
  final bool isPlaying;
  final bool showRecenterButton;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReplayCubit>();
    final duration = track.duration > Duration.zero
        ? track.duration
        : TrackCalculations.durationFromPoints(track.points);
    final maximumMilliseconds =
        duration.inMilliseconds == 0 ? 1 : duration.inMilliseconds;
    final instant = cubit.playbackInstant();
    final interpolated = TrackInterpolation.at(track.points, instant);
    final userPosition = cubit.playbackUserPosition();
    final visibleMarkers = track.markers
        .where((marker) => !marker.timestamp.isAfter(instant))
        .toList();
    final center = interpolated != null
        ? LatLng(interpolated.latitude, interpolated.longitude)
        : LatLng(track.points.first.latitude, track.points.first.longitude);
    final currentSpeedKilometersPerHour = interpolated?.speed != null
        ? TrackFormatters.metersPerSecondToKilometersPerHour(
            interpolated!.speed!,
          )
        : null;
    final distanceShare = _distanceUntil(track, playbackTime, duration);

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Map(
                controller: cubit.mapController,
                initialCenter: center,
                initialZoom: 16,
                userPosition: userPosition,
                recordingPoints: track.points,
                stops: track.stops,
                trackMarkers: visibleMarkers,
                showStartEndMarkers: true,
                onCameraChanged: cubit.onMapCameraChanged,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: LiveStatsOverlay(
                    distanceMeters: distanceShare,
                    elapsedTime: playbackTime,
                    currentSpeedKmh: currentSpeedKilometersPerHour,
                    averageSpeedKmh:
                        TrackFormatters.metersPerSecondToKilometersPerHour(
                      track.averageSpeedMps,
                    ),
                  ),
                ),
              ),
              if (showRecenterButton)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: RecenterButton(onPressed: cubit.recenterCamera),
                  ),
                ),
            ],
          ),
        ),
        Material(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              children: [
                Slider(
                  value: playbackTime.inMilliseconds
                      .clamp(0, maximumMilliseconds)
                      .toDouble(),
                  max: maximumMilliseconds.toDouble(),
                  onChanged: (value) {
                    cubit.seek(Duration(milliseconds: value.round()));
                  },
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: isPlaying ? cubit.pause : cubit.play,
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    ),
                    Text(TrackFormatters.formatDuration(playbackTime)),
                    const Text(' / '),
                    Text(TrackFormatters.formatDuration(duration)),
                    const Spacer(),
                    TextButton(
                      onPressed: cubit.cycleSpeed,
                      child: Text('${speed.toStringAsFixed(0)}x'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _distanceUntil(Track track, Duration time, Duration duration) {
    if (track.points.length < 2 || duration.inMilliseconds == 0) {
      return 0;
    }
    final fraction = time.inMilliseconds / duration.inMilliseconds;
    return track.distanceMeters * fraction.clamp(0, 1);
  }
}
