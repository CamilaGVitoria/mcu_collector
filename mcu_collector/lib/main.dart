import 'package:flutter/material.dart';
import 'views/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const McuCollectorApp());
}

class McuCollectorApp extends StatelessWidget {
  const McuCollectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCU Collector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE23636),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}