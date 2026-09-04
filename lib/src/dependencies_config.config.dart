// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:geotracker/src/data/data_module.dart' as _i871;
import 'package:geotracker/src/data/datasources/local_track_datasource.dart'
    as _i1013;
import 'package:geotracker/src/data/local/app_database.dart' as _i120;
import 'package:geotracker/src/data/mappers/track_mapper.dart' as _i945;
import 'package:geotracker/src/data/repositories/track_repository.dart'
    as _i873;
import 'package:geotracker/src/data/repositories/track_repository_impl.dart'
    as _i901;
import 'package:geotracker/src/features/details/presentation/details_cubit.dart'
    as _i821;
import 'package:geotracker/src/features/history/presentation/history_cubit.dart'
    as _i1024;
import 'package:geotracker/src/features/main/preseintation/main_cubit.dart'
    as _i17;
import 'package:geotracker/src/services/geolocation_service.dart' as _i310;
import 'package:geotracker/src/services/track_recording_service.dart' as _i129;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dataModule = _$DataModule();
    gh.singleton<_i310.GeolocationService>(() => _i310.GeolocationService());
    gh.lazySingleton<_i945.TrackMapper>(() => dataModule.trackMapper());
    gh.lazySingleton<_i120.AppDatabase>(() => _i120.AppDatabase());
    gh.lazySingleton<_i129.TrackRecordingService>(
      () => _i129.TrackRecordingService(gh<_i310.GeolocationService>()),
    );
    gh.lazySingleton<_i1013.LocalTrackDataSource>(
      () => _i1013.LocalTrackDataSource(
        gh<_i120.AppDatabase>(),
        gh<_i945.TrackMapper>(),
      ),
    );
    gh.lazySingleton<_i873.TrackRepository>(
      () => _i901.TrackRepositoryImpl(gh<_i1013.LocalTrackDataSource>()),
    );
    gh.factory<_i17.MainCubit>(
      () => _i17.MainCubit(
        gh<_i310.GeolocationService>(),
        gh<_i129.TrackRecordingService>(),
        gh<_i873.TrackRepository>(),
      ),
    );
    gh.factory<_i821.DetailsCubit>(
      () => _i821.DetailsCubit(gh<_i873.TrackRepository>()),
    );
    gh.factory<_i1024.HistoryCubit>(
      () => _i1024.HistoryCubit(gh<_i873.TrackRepository>()),
    );
    return this;
  }
}

class _$DataModule extends _i871.DataModule {}
