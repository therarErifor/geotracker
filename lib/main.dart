import 'package:flutter/material.dart';
import 'package:geotracker/src/core/app_log.dart';
import 'package:geotracker/src/dependencies_config.dart';
import 'package:geotracker/src/features/geotracker_app.dart';
import 'package:injectable/injectable.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLog.init();
  AppLog.i('App start');
  autoConfigDependencies(Environment.dev);
  runApp(const GeotrackerApp());
}
