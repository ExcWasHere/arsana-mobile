import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';

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

    // TODO: kirim _code ke backend buat diverifikasi beneran
    await Future.delayed(const Duration(milliseconds: 700));
    const dummyValidOtp = '123456'; // sementara buat testing UI

    setState(() => _isLoading = false);

    if (_code != dummyValidOtp) {
      setState(() => _hasError = true);
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(ProfileSetupScreen.routeName);
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    // TODO: panggil ulang endpoint kirim OTP
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
      body: SafeArea(
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