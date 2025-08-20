import 'package:flutter/material.dart';

class InitializationWidget extends StatelessWidget {
  const InitializationWidget({super.key});

  @override
  Widget build(BuildContext context) =>
      const SafeArea(child: Center(child: CircularProgressIndicator()));
}
