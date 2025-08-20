import 'package:geotracker/src/dependencies_config.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

GetIt container = GetIt.instance;

@InjectableInit(initializerName: 'init', asExtension: true)
void autoConfigDependencies(String? environment) =>
    container.init(environment: environment);