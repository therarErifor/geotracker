import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'main_cubit.dart';
import 'main_state.dart';

class MainScreen extends StatelessWidget {

  MainCubit? _cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        
        _cubit = context.read<MainCubit>();

        if (state is MainStateInit){
          return _buildMainInit(context, state);
        }
        
        if (state is MainStateLoaded){
          return _buildMainLoaded(context, state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMainInit(BuildContext context, MainStateInit state){
    return Placeholder();
  }

  Widget _buildMainLoaded(BuildContext context, MainStateLoaded state){
    return Placeholder();
  }
}