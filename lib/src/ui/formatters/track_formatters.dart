/// Shared presentation formatters for track stats and names.
class TrackFormatters {
  TrackFormatters._();

  static const double _metersPerKilometer = 1000;
  static const double _mpsToKmhFactor = 3.6;

  static const List<String> _monthAbbreviations = [
    'янв.',
    'февр.',
    'мар.',
    'апр.',
    'мая',
    'июн.',
    'июл.',
    'авг.',
    'сент.',
    'окт.',
    'нояб.',
    'дек.',
  ];

  static double mpsToKmh(double mps) => mps * _mpsToKmhFactor;

  static String formatDistanceKm(double meters) {
    if (meters < _metersPerKilometer) {
      return '${meters.round()} м';
    }
    final km = meters / _metersPerKilometer;
    return '${km.toStringAsFixed(1)} км';
  }

  static String formatDurationHms(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
    }
    return '$minutes:${_twoDigits(seconds)}';
  }

  static String formatSpeedKmh(double? kmh) {
    if (kmh == null) {
      return '—';
    }
    return '${kmh.toStringAsFixed(1)} км/ч';
  }

  /// Human-readable default track name, e.g. `4 сент. 2026, 13:35`.
  static String defaultTrackName(DateTime dateTime) {
    final local = dateTime.toLocal();
    final month = _monthAbbreviations[local.month - 1];
    return '${local.day} $month ${local.year}, '
        '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

/// Backward-compatible alias used by live UI.
typedef LiveFormatters = TrackFormatters;
