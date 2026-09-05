import 'package:flutter/material.dart';

class RecenterButton extends StatelessWidget {
  const RecenterButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 32,
        onPressed: onPressed,
        tooltip: 'Вернуться к трекингу',
        icon: const Icon(Icons.my_location),
      );
  }
}
