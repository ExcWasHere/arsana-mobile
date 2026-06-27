import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_background.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_auth_service.dart';
import '../home/home_screen.dart';

class OtpScreenArgs {
  final String identifier;
  final LoginMethod method;

  OtpScreenArgs({required this.identifier, required this.method});
}

class OtpScreen extends StatefulWidget {
  static const routeName = '/otp';
  final OtpScreenArgs args;

  const OtpScreen({super.key, required this.args});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _hasError = false;
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    setState(() => _hasError = false);
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_code.length == 6) _verify();
  }

  Future<void> _verify() async {
    setState(() => _isLoading = true);

    try {
      await SupabaseAuthService.instance.verifyOtp(
        identifier: widget.args.identifier,
        isPhone: widget.args.method == LoginMethod.phone,
        token: _code,
      );

      final alreadyHasProfile = await SupabaseAuthService.instance.hasProfile();
      if (!mounted) return;

      if (alreadyHasProfile) {
        Navigator.of(context).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false);
      } else {
        Navigator.of(context).pushReplacementNamed(ProfileSetupScreen.routeName);
      }
    } on AuthException catch (_) {
      setState(() => _hasError = true);
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kode OTP baru sudah dikirim')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verifikasi kode', style: theme.textTheme.displaySmall),
                const SizedBox(height: 8),
                Text(
                  'Masukkan 6 digit kode yang dikirim ke ${widget.args.identifier}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) => _buildOtpBox(i)),
                ),
                if (_hasError) ...[
                  const SizedBox(height: 12),
                  const Text('Kode salah, coba lagi ya', style: TextStyle(color: AppColors.error)),
                ],
                const SizedBox(height: 28),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _secondsLeft == 0 ? _resend : null,
                    child: Text(
                      _secondsLeft == 0
                          ? 'Kirim ulang kode'
                          : 'Kirim ulang dalam $_secondsLeft d',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _hasError ? AppColors.error : AppColors.primary.withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.cyanAccent, width: 1.8),
          ),
        ),
        onChanged: (v) => _onChanged(index, v),
      ),
    );
  }
}