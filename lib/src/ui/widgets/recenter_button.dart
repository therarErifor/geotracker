import 'package:flutter/material.dart';

class RecenterButton extends StatelessWidget {
  const RecenterButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shape: const CircleBorder(),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: IconButton(
        onPressed: onPressed,
        tooltip: 'Вернуться к трекингу',
        icon: const Icon(Icons.my_location),
      ),
    );
  }
}
