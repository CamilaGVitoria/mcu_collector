import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importe o pacote
import 'views/home_view.dart';
import 'views/auth_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis do arquivo .env
  await dotenv.load(fileName: ".env");

  // Inicializa o Supabase puxando as chaves de forma segura
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '',
  );

  runApp(const McuCollectorApp());
}

class McuCollectorApp extends StatelessWidget {
  const McuCollectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

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
      home: session != null ? const HomeView() : const AuthView(),
    );
  }
}