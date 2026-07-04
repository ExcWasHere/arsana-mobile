import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_storage_service.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/numeric_keypad.dart';
import '../../core/widgets/pin_dots.dart';
import '../home/home_screen.dart';
import 'biometric_setup_screen.dart';

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
  bool _isFaceId = false;
  String? _biometricNote;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final enabled = await AuthStorageService.instance.isBiometricEnabled();
    final available = await _auth.getAvailableBiometrics();
    if (!mounted) return;
    setState(() {
      _biometricEnabled = enabled;
      _isFaceId = available.contains(BiometricType.face);
    });
    if (enabled) _tryBiometric(silent: true);
  }

  Future<void> _tryBiometric({bool silent = false}) async {
    if (!_biometricEnabled) {
      final result = await Navigator.of(context).pushNamed(BiometricSetupScreen.routeName);
      if (result != null || mounted) await _init();
      return;
    }

    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Masuk ke Arsana',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (didAuthenticate) {
        await AuthStorageService.instance.extendSession();
        _goHome();
      }
    } catch (_) {
      if (!silent && mounted) {
        setState(() => _biometricNote = 'Gagal verifikasi biometrik, coba lagi atau pakai PIN ya');
      }
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
      await AuthStorageService.instance.extendSession();
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
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text('Masukkan PIN', style: theme.textTheme.displaySmall),
                const SizedBox(height: 12),
                _buildBiometricButton(),
                if (_biometricNote != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _biometricNote!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                PinDots(length: _pinLength, filled: _input.length, hasError: _hasError),
                if (_hasError) ...[
                  const SizedBox(height: 12),
                  const Text('PIN salah, coba lagi', style: TextStyle(color: AppColors.error)),
                ],
                const Spacer(),
                NumericKeypad(
                  onKeyTap: _onKeyTap,
                  onBackspace: _onBackspace,
                  showBiometric: false,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    final icon = _isFaceId ? Icons.face_retouching_natural : Icons.fingerprint;
    final label = _biometricEnabled
        ? (_isFaceId ? 'Masuk pakai Face ID' : 'Masuk pakai sidik jari')
        : 'Aktifkan Face ID / sidik jari';

    return TextButton.icon(
      onPressed: () => _tryBiometric(),
      icon: Icon(icon, color: AppColors.primary, size: 20),
      label: Text(
        label,
        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
      ),
    );
  }
}