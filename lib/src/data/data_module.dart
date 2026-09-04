import 'package:geotracker/src/data/mappers/track_mapper.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DataModule {
  @lazySingleton
  TrackMapper trackMapper() => const TrackMapper();
}
