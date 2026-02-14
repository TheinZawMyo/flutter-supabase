import 'package:flutter/material.dart';
import 'package:flutter_supabase/login_page.dart';
import 'package:flutter_supabase/widgets/connectivity_wrapper.dart';
import 'package:flutter_supabase/utils/keys.dart'; // Add this import

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracking',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      builder: (context, child) {
        return ConnectivityWrapper(child: child!);
      },
    );
  }
}
