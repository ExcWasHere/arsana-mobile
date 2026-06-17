import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Indikator bulatan buat nunjukin progress input PIN.
class PinDots extends StatelessWidget {
  final int length;
  final int filled;
  final bool hasError;

  const PinDots({
    super.key,
    required this.length,
    required this.filled,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = hasError ? AppColors.error : AppColors.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final isFilled = i < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? color : Colors.transparent,
            border: Border.all(color: color, width: 1.6),
          ),
        );
      }),
    );
  }
}