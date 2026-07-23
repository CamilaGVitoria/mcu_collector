import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'controllers/marvel_controller.dart';
import 'theme/app_colors.dart';
import 'views/home_view.dart';
import 'views/auth_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "env.txt");

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

    return ChangeNotifierProvider(
      create: (_) => MarvelController(),
      child: MaterialApp(
        title: 'MCU Collector',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.marvelRed,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: session != null ? const HomeView() : const AuthView(),
      ),
    );
  }
}
