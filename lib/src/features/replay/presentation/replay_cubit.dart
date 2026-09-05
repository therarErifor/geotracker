import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geotracker/src/data/repositories/track_repository.dart';
import 'package:geotracker/src/domain/pause_interval.dart';
import 'package:geotracker/src/domain/playback_timeline.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:geotracker/src/domain/track_calculations.dart';
import 'package:geotracker/src/domain/track_interpolation.dart';
import 'package:geotracker/src/entities/user_position.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import 'replay_state.dart';

@Injectable()
class ReplayCubit extends Cubit<ReplayState> {
  ReplayCubit(this._trackRepository) : super(const ReplayState.initial());

  static const List<double> playbackSpeeds = [1, 2, 5, 10, 50];

  final TrackRepository _trackRepository;
  final MapController mapController = MapController();

  Track? _track;
  List<PauseInterval> _gapPauses = const [];
  Duration _playbackTime = Duration.zero;
  double _speed = 1;
  bool _isPlaying = false;
  bool _cameraFollowEnabled = true;
  double _zoom = 16;
  Timer? _ticker;
  DateTime? _lastTick;

  Future<void> load(String trackId) async {
    emit(const ReplayState.loading());
    try {
      final track = await _trackRepository.getById(trackId);
      if (track == null) {
        emit(const ReplayState.error(error: 'Маршрут не найден'));
        return;
      }
      _track = track;
      _gapPauses = PlaybackTimeline.gapIntervals(
        stops: track.stops,
        points: track.points,
      );
      _playbackTime = Duration.zero;
      _speed = 1;
      _isPlaying = false;
      _cameraFollowEnabled = true;
      _emitLoaded();
    } catch (error) {
      emit(ReplayState.error(error: error));
    }
  }

  void play() {
    final track = _track;
    if (track == null || _isPlaying) {
      return;
    }
    if (_playbackTime >= _durationOf(track)) {
      _playbackTime = Duration.zero;
    }
    _isPlaying = true;
    _cameraFollowEnabled = true;
    _lastTick = DateTime.now();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), _onTick);
    _emitLoaded();
  }

  void pause() {
    _isPlaying = false;
    _ticker?.cancel();
    _ticker = null;
    _lastTick = null;
    _emitLoaded();
  }

  void seek(Duration time) {
    final track = _track;
    if (track == null) {
      return;
    }
    final maximum = _durationOf(track);
    if (time.isNegative) {
      _playbackTime = Duration.zero;
    } else if (time > maximum) {
      _playbackTime = maximum;
    } else {
      _playbackTime = time;
    }
    _followPlayback();
    _emitLoaded();
  }

  void cycleSpeed() {
    final index = playbackSpeeds.indexOf(_speed);
    _speed = playbackSpeeds[(index + 1) % playbackSpeeds.length];
    _emitLoaded();
  }

  void onMapCameraChanged(MapCamera camera, bool hasGesture) {
    _zoom = camera.zoom;
    if (hasGesture && _isPlaying) {
      _cameraFollowEnabled = false;
      _emitLoaded();
    }
  }

  void recenterCamera() {
    _cameraFollowEnabled = true;
    _followPlayback();
    _emitLoaded();
  }

  void _onTick(Timer timer) {
    final track = _track;
    if (track == null || !_isPlaying) {
      return;
    }
    final now = DateTime.now();
    final last = _lastTick ?? now;
    _lastTick = now;
    final elapsed = now.difference(last);
    final advanced = Duration(
      microseconds: (elapsed.inMicroseconds * _speed).round(),
    );
    final maximum = _durationOf(track);
    _playbackTime += advanced;
    if (_playbackTime >= maximum) {
      _playbackTime = maximum;
      pause();
      return;
    }
    _followPlayback();
    _emitLoaded();
  }

  Duration _durationOf(Track track) {
    if (track.duration > Duration.zero) {
      return track.duration;
    }
    return TrackCalculations.durationFromPoints(track.points);
  }

  DateTime playbackInstant() {
    final track = _track;
    if (track == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return PlaybackTimeline.wallClockAt(
      startedAt: track.startedAt,
      activeElapsed: _playbackTime,
      pauses: _gapPauses,
    );
  }

  void _followPlayback() {
    if (!_cameraFollowEnabled) {
      return;
    }
    final track = _track;
    if (track == null) {
      return;
    }
    final interpolated = TrackInterpolation.at(
      track.points,
      playbackInstant(),
    );
    if (interpolated == null) {
      return;
    }
    try {
      mapController.move(
        LatLng(interpolated.latitude, interpolated.longitude),
        _zoom,
      );
    } catch (_) {}
  }

  UserPosition? playbackUserPosition() {
    final track = _track;
    if (track == null) {
      return null;
    }
    final interpolated = TrackInterpolation.at(
      track.points,
      playbackInstant(),
    );
    if (interpolated == null) {
      return null;
    }
    return UserPosition(
      currentPosition: LatLng(interpolated.latitude, interpolated.longitude),
      heading: 0,
      speed: interpolated.speed,
    );
  }

  void _emitLoaded() {
    final track = _track;
    if (track == null) {
      return;
    }
    emit(
      ReplayState.loaded(
        track: track,
        playbackTime: _playbackTime,
        speed: _speed,
        isPlaying: _isPlaying,
        showRecenterButton: _isPlaying && !_cameraFollowEnabled,
      ),
    );
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
