import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/splash_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/home/home_page.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';
import 'services/trip_detector.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPrefs = await SharedPreferences.getInstance();
  await NotificationService.instance.initialize();
  await StorageService.instance.initialize();
  runApp(NatpacApp(sharedPrefs: sharedPrefs));
}

class NatpacApp extends StatelessWidget {
  final SharedPreferences sharedPrefs;
  const NatpacApp({super.key, required this.sharedPrefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState(sharedPrefs)),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => LocationService()),
        Provider(create: (_) => TripDetector()),
      ],
      child: MaterialApp(
        title: 'NATPAC Travel',
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.light,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const SplashPage(),
        routes: {
          LoginPage.route: (_) => const LoginPage(),
          SignupPage.route: (_) => const SignupPage(),
          HomePage.route: (_) => const HomePage(),
        },
      ),
    );
  }
}

