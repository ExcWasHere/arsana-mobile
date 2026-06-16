import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_storage_service.dart';
import '../home/home_screen.dart';

class BiometricSetupScreen extends StatefulWidget {
  static const routeName = '/biometric-setup';

  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  final _auth = LocalAuthentication();
  bool _isLoading = false;
  String? _availabilityNote;

  Future<void> _enableBiometric() async {
    setState(() {
      _isLoading = true;
      _availabilityNote = null;
    });

    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        setState(() {
          _isLoading = false;
          _availabilityNote = 'Perangkat ini belum mendukung Face ID / sidik jari';
        });
        return;
      }

      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Aktifkan Face ID / sidik jari untuk login Arsana',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );

      if (didAuthenticate) {
        await AuthStorageService.instance.setBiometricEnabled(true);
        _goHome();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
        _availabilityNote = 'Gagal mengaktifkan biometrik, coba lagi ya';
      });
    }
  }

  void _skip() {
    AuthStorageService.instance.setBiometricEnabled(false);
    _goHome();
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: AppColors.lightCyan,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fingerprint, size: 56, color: AppColors.primaryTeal),
              ),
              const SizedBox(height: 28),
              Text(
                'Login lebih cepat',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Aktifkan Face ID atau sidik jari biar kamu nggak perlu ketik PIN tiap kali masuk',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (_availabilityNote != null) ...[
                const SizedBox(height: 16),
                Text(
                  _availabilityNote!,
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: _isLoading ? null : _enableBiometric,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.white,
                        ),
                      )
                    : const Text('Aktifkan sekarang'),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: _isLoading ? null : _skip, child: const Text('Lewati dulu')),
            ],
          ),
        ),
      ),
    );
  }
}