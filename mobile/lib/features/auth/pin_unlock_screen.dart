import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_storage_service.dart';
import '../../core/widgets/numeric_keypad.dart';
import '../../core/widgets/pin_dots.dart';
import '../home/home_screen.dart';

const _pinLength = 6;

class PinUnlockScreen extends StatefulWidget {
  static const routeName = '/pin-unlock';

  const PinUnlockScreen({super.key});

  @override
  State<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends State<PinUnlockScreen> {
  final _auth = LocalAuthentication();
  String _input = '';
  bool _hasError = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final enabled = await AuthStorageService.instance.isBiometricEnabled();
    if (!mounted) return;
    setState(() => _biometricEnabled = enabled);
    if (enabled) _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Masuk ke Arsana',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (didAuthenticate) _goHome();
    } catch (_) {
      // user batal atau error -> biarin dia masukin PIN manual
    }
  }

  void _onKeyTap(String digit) {
    if (_input.length >= _pinLength) return;
    setState(() {
      _hasError = false;
      _input += digit;
    });
    if (_input.length == _pinLength) _verify();
  }

  void _onBackspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  Future<void> _verify() async {
    final isValid = await AuthStorageService.instance.verifyPin(_input);
    if (isValid) {
      _goHome();
    } else {
      setState(() {
        _hasError = true;
        _input = '';
      });
    }
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
            children: [
              const SizedBox(height: 48),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.lightCyan,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hearing, color: AppColors.primaryTeal, size: 32),
              ),
              const SizedBox(height: 20),
              Text('Masukkan PIN', style: theme.textTheme.displaySmall),
              const SizedBox(height: 28),
              PinDots(length: _pinLength, filled: _input.length, hasError: _hasError),
              if (_hasError) ...[
                const SizedBox(height: 12),
                const Text('PIN salah, coba lagi', style: TextStyle(color: AppColors.error)),
              ],
              const Spacer(),
              NumericKeypad(
                onKeyTap: _onKeyTap,
                onBackspace: _onBackspace,
                showBiometric: _biometricEnabled,
                onBiometricTap: _tryBiometric,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}