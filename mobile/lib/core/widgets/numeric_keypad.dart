import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Keypad numerik kustom buat input PIN.
/// Dipakai di pin_setup_screen.dart dan pin_unlock_screen.dart
class NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometricTap;
  final bool showBiometric;

  const NumericKeypad({
    super.key,
    required this.onKeyTap,
    required this.onBackspace,
    this.onBiometricTap,
    this.showBiometric = false,
  });

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: keys
                  .sublist(row * 3, row * 3 + 3)
                  .map((k) => _buildDigitKey(k))
                  .toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              showBiometric
                  ? _buildIconKey(Icons.fingerprint, onBiometricTap)
                  : const SizedBox(width: 72, height: 72),
              _buildDigitKey('0'),
              _buildIconKey(Icons.backspace_outlined, onBackspace),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDigitKey(String value) {
    return _KeypadButton(
      onTap: () => onKeyTap(value),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
    );
  }

  Widget _buildIconKey(IconData icon, VoidCallback? onTap) {
    return _KeypadButton(
      onTap: onTap,
      child: Icon(icon, color: AppColors.primary, size: 26),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _KeypadButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 72,
          height: 72,
          child: Center(child: child),
        ),
      ),
    );
  }
}