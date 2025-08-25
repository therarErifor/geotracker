import 'package:flutter/material.dart';
import 'package:geotracker/src/dependencies_config.dart';
import 'package:geotracker/src/features/bike_tracker_app.dart';
import 'package:injectable/injectable.dart';

void main() {
  autoConfigDependencies(Environment.dev);
  runApp(const TropaApp());
}