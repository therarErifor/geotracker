// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:geotracker/src/features/main/preseintation/main_cubit.dart'
    as _i17;
import 'package:geotracker/src/services/geolocation_service.dart' as _i310;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i310.GeolocationService>(() => _i310.GeolocationService());
    gh.factory<_i17.MainCubit>(
        () => _i17.MainCubit(gh<_i310.GeolocationService>()));
    return this;
  }
}
