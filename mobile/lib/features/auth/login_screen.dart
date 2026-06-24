import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/google_logo.dart';
import '../home/home_screen.dart';
import 'profile_setup_screen.dart';
import 'otp_screen.dart';

enum LoginMethod { phone, email }

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginMethod _method = LoginMethod.phone;
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  bool _isLoading = false;

  // Flag ini biar listener cuma bereaksi waktu Google OAuth yang diinisiasi
  // dari screen ini (bukan signedIn dari OTP atau session restore)
  bool _googleAuthInProgress = false;
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      _onAuthStateChange,
    );
  }

  Future<void> _onAuthStateChange(AuthState data) async {
    if (data.event != AuthChangeEvent.signedIn) return;
    if (!_googleAuthInProgress) return;
    _googleAuthInProgress = false;

    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final hasProfile = await SupabaseAuthService.instance.hasProfile();
      if (!mounted) return;
      if (hasProfile) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          HomeScreen.routeName,
          (_) => false,
        );
      } else {
        Navigator.of(context).pushReplacementNamed(
          ProfileSetupScreen.routeName,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    _inputController.dispose();
    super.dispose();
  }

  void _switchMethod(LoginMethod method) {
    if (_method == method) return;
    setState(() {
      _method = method;
      _inputController.clear();
    });
  }

  String? _validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _method == LoginMethod.phone
          ? 'Nomor HP wajib diisi'
          : 'Email wajib diisi';
    }
    if (_method == LoginMethod.email) {
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(value.trim())) {
        return 'Format email belum bener';
      }
    } else {
      final phoneRegex = RegExp(r'^[0-9+]{9,15}$');
      if (!phoneRegex.hasMatch(value.trim())) {
        return 'Format nomor HP belum bener';
      }
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await SupabaseAuthService.instance.sendOtp(
        identifier: _inputController.text.trim(),
        isPhone: _method == LoginMethod.phone,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        OtpScreen.routeName,
        arguments: OtpScreenArgs(
          identifier: _inputController.text.trim(),
          method: _method,
        ),
      );
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _googleAuthInProgress = true;
    });
    try {
      final launched = await SupabaseAuthService.instance.signInWithGoogle();
      if (!launched) {
        _googleAuthInProgress = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membuka halaman Google Sign In')),
          );
        }
      }
      // Kalau launched = true, user lagi di browser
      // Navigasi akan ditangani _onAuthStateChange setelah deep link balik
    } on AuthException catch (e) {
      _googleAuthInProgress = false;
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      _googleAuthInProgress = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal masuk dengan Google, coba lagi ya')),
        );
      }
    } finally {
      // Loading tetap true kalau launched berhasil — akan di-clear di _onAuthStateChange
      if (mounted && !_googleAuthInProgress) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.hearing, size: 40, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  'Selamat datang di Arsana',
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Masuk pakai nomor HP, email, atau akun Google kamu buat mulai belajar',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                _buildMethodSwitch(),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _inputController,
                  keyboardType: _method == LoginMethod.phone
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: _method == LoginMethod.phone
                        ? '08xxxxxxxxxx'
                        : 'nama@email.com',
                    prefixIcon: Icon(
                      _method == LoginMethod.phone
                          ? Icons.phone_outlined
                          : Icons.email_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  validator: _validate,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: AppColors.white,
                          ),
                        )
                      : const Text('Lanjut'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color: AppColors.ink.withValues(alpha: 0.15))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('atau', style: theme.textTheme.bodyMedium),
                    ),
                    Expanded(
                        child: Divider(
                            color: AppColors.ink.withValues(alpha: 0.15))),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _loginWithGoogle,
                  icon: const GoogleLogo(size: 20),
                  label: const Text('Masuk dengan Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: BorderSide(
                        color: AppColors.ink.withValues(alpha: 0.15)),
                    foregroundColor: AppColors.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildMethodSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.lightCyan,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildMethodTab('No. HP', LoginMethod.phone),
          _buildMethodTab('Email', LoginMethod.email),
        ],
      ),
    );
  }

  Widget _buildMethodTab(String label, LoginMethod method) {
    final selected = _method == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMethod(method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.08),
                        blurRadius: 8)
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected
                  ? AppColors.primary
                  : AppColors.ink.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}