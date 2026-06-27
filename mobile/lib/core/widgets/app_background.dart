import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/images/latar-belakang.svg',
            fit: BoxFit.cover,
          ),
        ),
        child,
      ],
    );
  }
}