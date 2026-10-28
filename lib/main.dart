import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/app_bloc.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/api_client.dart';
import 'services/firebase_service.dart';
import 'services/token_storage.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeAndGetToken();
  await TokenStorage.init();

  ApiClient.onSessionExpired = () {
    rootNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  };

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(const IDFDigitalHubApp());
}

class IDFDigitalHubApp extends StatelessWidget {
  const IDFDigitalHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc(),
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        title: 'MDRF Activate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
