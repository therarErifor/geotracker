import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geotracker/src/dependencies_config.dart';
import 'package:geotracker/src/widgets/widgets_export.dart';
import 'main_cubit.dart';
import 'main_state.dart';

class MainScreen extends StatelessWidget {
  MainCubit? _cubit;

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
      orElse: ()=> const LoadingErrorWidget(),
      init: ()=> const InitializationWidget(),
      loaded: (options)=> _buildLoaded(context, options),
      tracking: ()=> _buildTracking(context),
      
    );
  }

  Widget _buildLoaded(BuildContext context, MapOptions options) {
    return FlutterMap(options: options, children: [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      )
    ]);
  }

  Widget _buildTracking(BuildContext context) {
    return const Placeholder();
  }

  Widget _buildFinish(BuildContext context, state) {
    return const Placeholder();
  }
}
