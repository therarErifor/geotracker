import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geotracker/src/dependencies_config.dart';
import 'package:geotracker/src/domain/track_point.dart';
import 'package:geotracker/src/entities/error_type.dart';
import 'package:geotracker/src/entities/tracking_status.dart';
import 'package:geotracker/src/entities/user_position.dart';
import 'package:geotracker/src/features/history/presentation/history_page.dart';
import 'package:geotracker/src/ui/widgets/tracking_buttons.dart';
import 'package:geotracker/src/ui/widgets/widgets_export.dart';
import 'package:latlong2/latlong.dart';

import 'main_cubit.dart';
import 'main_state.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider<MainCubit>(
          create: (_) => container<MainCubit>(),
          child: BlocListener<MainCubit, MainState>(
            listenWhen: (previous, current) {
              return _saveError(current) != null &&
                  _saveError(current) != _saveError(previous);
            },
            listener: (context, state) {
              final message = _saveError(state);
              if (message == null) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
              context.read<MainCubit>().clearSaveError();
            },
            child: BlocBuilder<MainCubit, MainState>(builder: _buildBody),
          ),
        ),
      ),
    );
  }

  static String? _saveError(MainState state) {
    return state.maybeMap(
      loaded: (loaded) => loaded.saveError,
      orElse: () => null,
    );
  }

  Widget _buildBody(BuildContext context, MainState state) {
    return state.maybeWhen(
      error: (error) {
        final cubit = context.read<MainCubit>();

        if (error == ErrorType.permissionDenied) {
          return LoadingErrorWidget(
            errorText:
                'Приложению отказано пользоваться службой определения местоположения',
            buttonText: 'Открыть настройки приложения',
            callback: () => cubit.openAppSettings(),
          );
        }
        return LoadingErrorWidget(
          errorText: error.toString(),
          buttonText: 'Перезагрузить',
          callback: () => cubit.init(),
        );
      },
      loaded: (
        trackingStatus,
        userPosition,
        initialMapCenter,
        initialMapZoom,
        recordingPoints,
        distanceMeters,
        elapsedTime,
        currentSpeedKmh,
        averageSpeedKmh,
        showRecenterButton,
        saveError,
      ) =>
          _buildLoaded(
            context,
            trackingStatus: trackingStatus,
            userPosition: userPosition,
            initialMapCenter: initialMapCenter,
            initialMapZoom: initialMapZoom,
            recordingPoints: recordingPoints,
            distanceMeters: distanceMeters,
            elapsedTime: elapsedTime,
            currentSpeedKmh: currentSpeedKmh,
            averageSpeedKmh: averageSpeedKmh,
            showRecenterButton: showRecenterButton,
          ),
      orElse: () => const InitializationWidget(),
    );
  }

  Widget _buildLoaded(
    BuildContext context, {
    required TrackingStatus trackingStatus,
    required UserPosition? userPosition,
    required LatLng initialMapCenter,
    required double initialMapZoom,
    required List<TrackPoint> recordingPoints,
    required double distanceMeters,
    required Duration elapsedTime,
    required double? currentSpeedKmh,
    required double averageSpeedKmh,
    required bool showRecenterButton,
  }) {
    final cubit = context.read<MainCubit>();
    final showStats = trackingStatus != TrackingStatus.rest;

    return Stack(
      children: [
        Map(
          controller: cubit.mapController,
          initialCenter: initialMapCenter,
          initialZoom: initialMapZoom,
          userPosition: userPosition,
          recordingPoints: recordingPoints,
          onCameraChanged: cubit.onMapCameraChanged,
        ),
        if (showStats)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LiveStatsOverlay(
                distanceMeters: distanceMeters,
                elapsedTime: elapsedTime,
                currentSpeedKmh: currentSpeedKmh,
                averageSpeedKmh: averageSpeedKmh,
              ),
            ),
          ),
        Align(
          alignment: AlignmentDirectional.topStart,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HistoryPage(),
                  ),
                );
              },
              iconSize: 32,
              icon: const Icon(Icons.menu_rounded),
            ),
          ),
        ),
        if (showRecenterButton)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 80),
              child: RecenterButton(onPressed: cubit.recenterCamera),
            ),
          ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: NavigationButtons(
            zoomIn: cubit.zoomIn,
            zoomOut: cubit.zoomOut,
            findMe: cubit.findMe,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TrackingButtons(
              trackingStatus: trackingStatus,
              tracking: cubit.tracking,
              pauseTracking: cubit.pauseTracking,
              finishTracking: cubit.finishTracking,
              saveTrack: cubit.saveTrack,
              deleteTrack: cubit.deleteTrack,
            ),
          ),
        ),
      ],
    );
  }
}
