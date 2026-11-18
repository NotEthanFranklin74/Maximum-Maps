import 'package:flutter/material.dart';
import 'features/map/pages/map.page.dart';

void main() {
  runApp(const MaximumMapsApp());
}

class MaximumMapsApp extends StatelessWidget {
  const MaximumMapsApp({ super.key });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Maximum Maps",
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),

      home: const MapPage(),
    );
  }
}