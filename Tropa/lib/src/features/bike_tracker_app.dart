import 'package:flutter/material.dart';

import 'main/preseintation/main_screen.dart';

class TropaApp extends StatelessWidget {
  const TropaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      title: 'Tropa',
      home:
          MainScreen(),
    );
  }
}
