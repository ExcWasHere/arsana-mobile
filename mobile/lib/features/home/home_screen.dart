import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_storage_service.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthStorageService.instance.clearAll();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mist,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration_outlined, size: 64, color: AppColors.primaryTeal),
              const SizedBox(height: 16),
              Text('Selamat datang di Arsana!', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              TextButton(onPressed: () => _logout(context), child: const Text('Keluar (testing)')),
            ],
          ),
        ),
      ),
    );
  }
}