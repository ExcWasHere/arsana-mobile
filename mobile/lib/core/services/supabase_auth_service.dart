import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  SupabaseAuthService._();
  static final instance = SupabaseAuthService._();

  SupabaseClient get _client => Supabase.instance.client;

  String _toE164(String localPhone) {
    final digits = localPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0')) return '+62${digits.substring(1)}';
    if (digits.startsWith('62')) return '+$digits';
    return '+$digits';
  }

  Future<void> sendOtp({
    required String identifier,
    required bool isPhone,
  }) async {
    if (isPhone) {
      await _client.auth.signInWithOtp(phone: _toE164(identifier));
    } else {
      await _client.auth.signInWithOtp(email: identifier);
    }
  }

  Future<AuthResponse> verifyOtp({
    required String identifier,
    required bool isPhone,
    required String token,
  }) {
    if (isPhone) {
      return _client.auth.verifyOTP(
        type: OtpType.sms,
        token: token,
        phone: _toE164(identifier),
      );
    }
    return _client.auth.verifyOTP(
      type: OtpType.email,
      token: token,
      email: identifier,
    );
  }

  /// Login Google via Supabase OAuth — buka browser, redirect ke supabase.co/google,
  /// lalu balik ke app lewat deep link arsana://login-callback.
  /// Return true kalau browser berhasil diluncurkan.
  Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'arsana://login-callback',
    );
  }

  Future<bool> hasProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    final row = await _client
        .from('profiles')
        .select('id')
        .eq('id', userId)
        .maybeSingle();
    return row != null;
  }

  Future<void> signOut() => _client.auth.signOut();
}