import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_storage_service.dart';
import '../../core/widgets/numeric_keypad.dart';
import '../../core/widgets/pin_dots.dart';
import 'biometric_setup_screen.dart';

const _pinLength = 6;

class PinSetupScreen extends StatefulWidget {
  static const routeName = '/pin-setup';

  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _firstPin = '';
  String _currentInput = '';
  bool _isConfirmStep = false;
  bool _hasError = false;

  void _onKeyTap(String digit) {
    if (_currentInput.length >= _pinLength) return;
    setState(() {
      _hasError = false;
      _currentInput += digit;
    });
    if (_currentInput.length == _pinLength) _onComplete();
  }

  void _onBackspace() {
    if (_currentInput.isEmpty) return;
    setState(() => _currentInput = _currentInput.substring(0, _currentInput.length - 1));
  }

  Future<void> _onComplete() async {
    if (!_isConfirmStep) {
      setState(() {
        _firstPin = _currentInput;
        _currentInput = '';
        _isConfirmStep = true;
      });
      return;
    }

    if (_currentInput != _firstPin) {
      setState(() {
        _hasError = true;
        _currentInput = '';
      });
      return;
    }

    await AuthStorageService.instance.savePin(_firstPin);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(BiometricSetupScreen.routeName);
  }

  void _backToFirstStep() {
    setState(() {
      _isConfirmStep = false;
      _currentInput = '';
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: _isConfirmStep
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _backToFirstStep,
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                _isConfirmStep ? 'Konfirmasi PIN kamu' : 'Buat PIN baru',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _isConfirmStep
                    ? 'Masukkan ulang PIN yang sama'
                    : 'PIN ini dipakai buat login berikutnya',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              PinDots(length: _pinLength, filled: _currentInput.length, hasError: _hasError),
              if (_hasError) ...[
                const SizedBox(height: 12),
                const Text('PIN tidak sama, coba lagi', style: TextStyle(color: AppColors.error)),
              ],
              const Spacer(),
              NumericKeypad(onKeyTap: _onKeyTap, onBackspace: _onBackspace),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}