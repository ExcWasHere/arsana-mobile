import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_colors.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/auth/profile_setup_screen.dart';
import 'features/auth/pin_setup_screen.dart';
import 'features/auth/biometric_setup_screen.dart';
import 'features/auth/pin_unlock_screen.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const ArsanaApp());
}

class ArsanaApp extends StatelessWidget {
  const ArsanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arsana',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        ProfileSetupScreen.routeName: (_) => const ProfileSetupScreen(),
        PinSetupScreen.routeName: (_) => const PinSetupScreen(),
        BiometricSetupScreen.routeName: (_) => const BiometricSetupScreen(),
        PinUnlockScreen.routeName: (_) => const PinUnlockScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
      },
      // OtpScreen butuh argumen, jadi ditangani manual lewat onGenerateRoute
      onGenerateRoute: (settings) {
        if (settings.name == OtpScreen.routeName) {
          final args = settings.arguments as OtpScreenArgs;
          return MaterialPageRoute(builder: (_) => OtpScreen(args: args));
        }
        return null;
      },
    );
  }
}