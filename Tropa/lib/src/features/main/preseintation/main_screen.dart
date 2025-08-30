import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geotracker/src/dependencies_config.dart';
import 'package:geotracker/src/entities/error_type.dart';
import 'package:geotracker/src/ui/widgets/tracking_buttons.dart';
import 'package:geotracker/src/ui/widgets/widgets_export.dart';
import '../../../entities/tracking_status.dart';
import '../../../entities/user_position.dart';
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
          child: BlocBuilder<MainCubit, MainState>(builder: _buildBody),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MainState state) {
    return state.maybeWhen(
      error: (error) {
        MainCubit? cubit = context.read<MainCubit>();

        if (error == ErrorType.permissionDenied) {
          return LoadingErrorWidget(
            errorText:
                'Приложению отказано пользоваться службой определения местоположения',
            buttonText: 'Открыть настройки приложения',
            callback: () => cubit.openAppSettings(),
          );
        }
        // if (error == ErrorType.locationServicesDisabled) {
        //   return LoadingErrorWidget(
        //     errorText: 'Служба определения местоположения отключена',
        //     buttonText: 'Включить геолокацию',
        //     callback: ()=> cubit.openLocationSettings(),
        //   );
        // }
        return LoadingErrorWidget(
          errorText: error.toString(),
          buttonText: 'Перезагрузить',
          callback: () => cubit.init(),
        );
      },
      loaded: (options, mapController, trackingStatus, userPosition) =>
          _buildLoaded(
            context,
            options,
            mapController,
            trackingStatus,
            userPosition,
          ),
      orElse: () => const InitializationWidget(),
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    MapOptions options,
    MapController mapController,
    TrackingStatus trackingStatus,
    UserPosition? userPosition,
  ) {
    MainCubit? cubit = context.read<MainCubit>();
    return Stack(
      children: [
        Map(
          options: options,
          controller: mapController,
          userPosition: userPosition,
        ),
        Align(
          alignment: AlignmentDirectional.topStart,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IconButton(
              onPressed: () {},
              iconSize: 32,
              icon: Icon(Icons.menu_rounded),
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: NavigationButtons(
            zoomIn: () => cubit.zoomIn(),
            zoomOut: () => cubit.zoomOut(),
            findMe: () => cubit.findMe(),
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
