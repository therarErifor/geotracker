import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geotracker/src/dependencies_config.dart';
import 'package:geotracker/src/ui/widgets/widgets_export.dart';
import 'main_cubit.dart';
import 'main_state.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider<MainCubit>(
            create: (_) => container<MainCubit>(),
            child: BlocBuilder<MainCubit, MainState>(
              builder: _buildBody,
            )),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MainState state) {
    return state.maybeWhen(
      orElse: () => const LoadingErrorWidget(),
      init: () => const InitializationWidget(),
      loaded: (options, mapController) =>
          _buildLoaded(context, options, mapController),
      tracking: () => _buildTracking(context),
    );
  }

  Widget _buildLoaded(
      BuildContext context, MapOptions options, MapController mapController) {
    return Stack(children: [
      Map(options: options, controller: mapController),
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: NavigationButtons(
          zoomIn: ()=> context.read<MainCubit>().zoomIn(),
          zoomOut: ()=> context.read<MainCubit>().zoomOut(),
          findMe: ()=> context.read<MainCubit>().findMe()
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton(
            onPressed: () => context.read<MainCubit>().startTracking(),
            child: const Text('Старт'),
          ),
        ),
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
