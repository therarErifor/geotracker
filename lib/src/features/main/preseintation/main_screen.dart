import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geotracker/src/dependencies_config.dart';
import 'package:geotracker/src/domain/marker.dart';
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
          child: MultiBlocListener(
            listeners: [
              BlocListener<MainCubit, MainState>(
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
              ),
              BlocListener<MainCubit, MainState>(
                listenWhen: (previous, current) {
                  return _sessionInterruptedMessage(current) != null &&
                      _sessionInterruptedMessage(current) !=
                          _sessionInterruptedMessage(previous);
                },
                listener: (context, state) {
                  final message = _sessionInterruptedMessage(state);
                  if (message == null) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                  context.read<MainCubit>().clearSessionInterruptedMessage();
                },
              ),
            ],
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

  static String? _sessionInterruptedMessage(MainState state) {
    return state.maybeMap(
      loaded: (loaded) => loaded.sessionInterruptedMessage,
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
        trackMarkers,
        saveError,
        sessionInterruptedMessage,
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
            trackMarkers: trackMarkers,
          ),
      orElse: () => const InitializationWidget(),
    );
  }

  Future<void> _promptAddMarker(
    BuildContext context,
    MainCubit cubit,
    LatLng point,
  ) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Новый маркер'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Название'),
                textCapitalization: TextCapitalization.sentences,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );

    if (submitted != true || !context.mounted) {
      titleController.dispose();
      descriptionController.dispose();
      return;
    }

    final error = cubit.addMarker(
      latitude: point.latitude,
      longitude: point.longitude,
      title: titleController.text,
      description: descriptionController.text,
    );
    titleController.dispose();
    descriptionController.dispose();
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
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
    required List<Marker> trackMarkers,
  }) {
    final cubit = context.read<MainCubit>();
    final showStats = trackingStatus != TrackingStatus.rest;
    final canPlaceMarker = trackingStatus == TrackingStatus.tracking ||
        trackingStatus == TrackingStatus.pause;

    return Stack(
      children: [
        Map(
          controller: cubit.mapController,
          initialCenter: initialMapCenter,
          initialZoom: initialMapZoom,
          userPosition: userPosition,
          recordingPoints: recordingPoints,
          trackMarkers: trackMarkers,
          onCameraChanged: cubit.onMapCameraChanged,
          onTap: canPlaceMarker
              ? (point) => _promptAddMarker(context, cubit, point)
              : null,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canPlaceMarker)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final position = cubit.currentMarkerPosition();
                        if (position == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Нет текущих координат'),
                            ),
                          );
                          return;
                        }
                        _promptAddMarker(context, cubit, position);
                      },
                      icon: const Icon(Icons.add_location_alt),
                      label: const Text('Маркер'),
                    ),
                  ),
                TrackingButtons(
                  trackingStatus: trackingStatus,
                  tracking: cubit.tracking,
                  pauseTracking: cubit.pauseTracking,
                  finishTracking: cubit.finishTracking,
                  saveTrack: cubit.saveTrack,
                  deleteTrack: cubit.deleteTrack,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
