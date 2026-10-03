import 'package:flutter/material.dart';

import 'presentation/screens/parking_screen.dart';

class ParkingApp extends StatelessWidget {
  const ParkingApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Parkuj czy przesiądź się?',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF2F6F8),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF006D77),
        primary: const Color(0xFF006D77),
        surface: Colors.white,
      ),
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: const Color(0xFF142A36),
        displayColor: const Color(0xFF142A36),
      ),
    ),
    home: const ParkingScreen(),
  );
}
