import 'package:flutter/material.dart';
import 'package:geotracker/src/features/main/preseintation/locate_button_kind.dart';
import 'package:geotracker/src/ui/widgets/recenter_button.dart';

class NavigationButtons extends StatelessWidget {
  const NavigationButtons({
    required this.zoomIn,
    required this.zoomOut,
    required this.locateKind,
    required this.onLocate,
    super.key,
  });

  final VoidCallback zoomIn;
  final VoidCallback zoomOut;
  final LocateButtonKind locateKind;
  final VoidCallback onLocate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: zoomIn,
          iconSize: 32,
          icon: const Icon(Icons.add_circle),
        ),
        IconButton(
          onPressed: zoomOut,
          iconSize: 32,
          icon: const Icon(Icons.remove_circle),
        ),
        switch (locateKind) {
          LocateButtonKind.hidden => const SizedBox(height: 48, width: 32),
          LocateButtonKind.findMe => IconButton(
              onPressed: onLocate,
              iconSize: 32,
              tooltip: 'Найти пользователя',
              icon: const Icon(Icons.pin_drop_rounded),
            ),
          LocateButtonKind.followUser => RecenterButton(onPressed: onLocate),
        },
      ],
    );
  }
}
