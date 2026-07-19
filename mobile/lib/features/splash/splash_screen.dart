import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_storage_service.dart';
import '../auth/login_screen.dart';
import '../auth/pin_unlock_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _logoAssetPath = 'assets/images/logo_fix.png';

  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final AnimationController _exitController;
  late final Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _exitFade = CurvedAnimation(parent: _exitController, curve: Curves.easeInOut);

    _controller.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 1800));

    final hasPin = await AuthStorageService.instance.hasPin();
    if (!mounted) return;

    await _exitController.forward();
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(
      hasPin ? PinUnlockScreen.routeName : LoginScreen.routeName,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_controller, _exitController]),
          builder: (context, child) {
            return Opacity(
              opacity: _fadeIn.value * (1 - _exitFade.value),
              child: child,
            );
          },
          child: Image.asset(
            _logoAssetPath,
            width: 260,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}