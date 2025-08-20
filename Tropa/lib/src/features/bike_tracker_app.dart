import 'package:flutter/material.dart';

import 'main/preseintation/main_screen.dart';

class GeotrackerApp extends StatelessWidget {
  const GeotrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home:
          MainScreen(),
    );
  }
}
