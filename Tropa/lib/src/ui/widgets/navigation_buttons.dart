import 'package:flutter/material.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback zoomIn;
  final VoidCallback zoomOut;
  final VoidCallback findMe;

  const NavigationButtons({required this.zoomIn, required this.zoomOut, required this.findMe, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => zoomIn(),
              iconSize: 32,
              icon: Icon(Icons.add_circle),
            ),
            IconButton(
              onPressed: () => zoomOut(),
              iconSize: 32,
              icon: Icon(Icons.remove_circle),
            ),
            IconButton(
              onPressed: () => findMe(),
              iconSize: 32,
              icon: Icon(Icons.pin_drop_rounded),
            ),
          ],
        );
  }
}