class TrackFormatters {
  TrackFormatters._();

  static const double _metersPerKilometer = 1000;
  static const double _metersPerSecondToKilometersPerHourFactor = 3.6;

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

  static double metersPerSecondToKilometersPerHour(double metersPerSecond) =>
      metersPerSecond * _metersPerSecondToKilometersPerHourFactor;

  static String formatDistanceKm(double meters) {
    if (meters < _metersPerKilometer) {
      return '${meters.round()} м';
    }
    final kilometers = meters / _metersPerKilometer;
    return '${kilometers.toStringAsFixed(1)} км';
  }

  static String formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
    }
    return '$minutes:${_twoDigits(seconds)}';
  }

  static String formatSpeedKmh(double? kilometersPerHour) {
    if (kilometersPerHour == null) {
      return '—';
    }
    return '${kilometersPerHour.toStringAsFixed(1)} км/ч';
  }

  static String defaultTrackName(DateTime dateTime) {
    final local = dateTime.toLocal();
    final month = _monthAbbreviations[local.month - 1];
    return '${local.day} $month ${local.year}, '
        '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
