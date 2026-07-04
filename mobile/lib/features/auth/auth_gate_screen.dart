import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/auth_storage_service.dart';
import '../../core/services/supabase_auth_service.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';
import 'pin_setup_screen.dart';
import 'pin_unlock_screen.dart';

class AuthGateScreen extends StatefulWidget {
  static const routeName = '/auth-gate';

  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideRoute());
  }

  Future<void> _decideRoute() async {
    final supabaseSession = Supabase.instance.client.auth.currentSession;
    final sessionValid = await AuthStorageService.instance.isSessionValid();
    if (supabaseSession == null || !sessionValid) {
      await AuthStorageService.instance.clearAll();
      await SupabaseAuthService.instance.signOut();
      _go(LoginScreen.routeName);
      return;
    }

    final hasProfile = await SupabaseAuthService.instance.hasProfile();
    if (!hasProfile) {
      _go(ProfileSetupScreen.routeName);
      return;
    }

    final hasPin = await AuthStorageService.instance.hasPin();
    if (!hasPin) {
      _go(PinSetupScreen.routeName);
      return;
    }

    _go(PinUnlockScreen.routeName);
  }

  void _go(String routeName) {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}