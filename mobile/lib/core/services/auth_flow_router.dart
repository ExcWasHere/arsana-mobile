import 'package:flutter/material.dart';
import 'auth_storage_service.dart';
import 'supabase_auth_service.dart';
import '../../features/auth/profile_setup_screen.dart';
import '../../features/auth/pin_setup_screen.dart';
import '../../features/home/home_screen.dart';

class AuthFlowRouter {
  AuthFlowRouter._();

  static Future<void> routeAfterFullLogin(BuildContext context) async {
    final hasProfile = await SupabaseAuthService.instance.hasProfile();
    if (!hasProfile) {
      _go(context, ProfileSetupScreen.routeName);
      return;
    }

    final hasPin = await AuthStorageService.instance.hasPin();
    if (!hasPin) {
      _go(context, PinSetupScreen.routeName);
      return;
    }

    await AuthStorageService.instance.extendSession();
    _go(context, HomeScreen.routeName);
  }

  static void _go(BuildContext context, String routeName) {
    Navigator.of(context).pushNamedAndRemoveUntil(routeName, (_) => false);
  }
}