import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geotracker/src/dependencies_config.dart';
import 'package:geotracker/src/ui/widgets/widgets_export.dart';
import 'main_cubit.dart';
import 'main_state.dart';

class MainScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with TickerProviderStateMixin {

late final _animatedMapController = AnimatedMapController(vsync: this);
late MainCubit cubit;

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MainCubit>(
        create: (_) => container<MainCubit>(param1: _animatedMapController),
        child: BlocBuilder<MainCubit, MainState>(
          builder: _buildBody,
        ));
  }

  Widget _buildBody(BuildContext context, MainState state) {
    return state.maybeWhen(
      orElse: () => const LoadingErrorWidget(),
      init: () => const InitializationWidget(),
      loaded: (trackingStatus, options, animatedMapController) =>
          _buildMap(context, trackingStatus, options, animatedMapController.mapController),
    );
  }

  Widget _buildMap(BuildContext context, TrackingStatus trackingStatus,
      MapOptions options, MapController mapController) {
    cubit = context.read<MainCubit>();

    final size = MediaQuery.of(context).size;
    return Stack(alignment: Alignment.bottomCenter, children: [
      Map(options: options, controller: mapController),
      Positioned(
        top: size.height / 2,
        right: 8,
        child: NavigationButtons(
            zoomIn: () => cubit.zoomIn(),
            zoomOut: () => cubit.zoomOut(),
            findMe: () => cubit.findMe()),
      ),
      TrackerButtons(
        trackingStatus: trackingStatus,
        startTracking: () => cubit.startTracking(),
        pauseTracking: () => cubit.pauseTracking(),
        finishTracking: () => cubit.finishTracking(),
      ),
    ]);
  }

  Widget _buildTracking(BuildContext context) {
    return const Placeholder();
  }

  Widget _buildFinish(BuildContext context, state) {
    return const Placeholder();
  }
}
