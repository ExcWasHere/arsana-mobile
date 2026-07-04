import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class AuthStorageService {
  AuthStorageService._();
  static final AuthStorageService instance = AuthStorageService._();

  final _storage = const FlutterSecureStorage();

  static const _keyPin = 'arsana_pin';
  static const _keyBiometricEnabled = 'arsana_biometric_enabled';
  static const _keyProfileComplete = 'arsana_profile_complete';
  static const _keySessionExpiry = 'arsana_session_expiry';
  static const _sessionDuration = Duration(days: 30);

  Future<void> savePin(String pin) => _storage.write(key: _keyPin, value: pin);

  Future<bool> verifyPin(String pin) async {
    final saved = await _storage.read(key: _keyPin);
    return saved != null && saved == pin;
  }

  Future<bool> hasPin() async {
    final saved = await _storage.read(key: _keyPin);
    return saved != null;
  }

  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(key: _keyBiometricEnabled, value: enabled.toString());

  Future<bool> isBiometricEnabled() async {
    final v = await _storage.read(key: _keyBiometricEnabled);
    return v == 'true';
  }

  Future<void> setProfileComplete(bool complete) =>
      _storage.write(key: _keyProfileComplete, value: complete.toString());

  Future<bool> isProfileComplete() async {
    final v = await _storage.read(key: _keyProfileComplete);
    return v == 'true';
  }

  Future<void> extendSession() =>
      _storage.write(
        key: _keySessionExpiry,
        value: DateTime.now().add(_sessionDuration).toIso8601String(),
      );

  Future<bool> isSessionValid() async {
    final saved = await _storage.read(key: _keySessionExpiry);
    if (saved == null) return false;
    final expiry = DateTime.tryParse(saved);
    if (expiry == null) return false;
    return DateTime.now().isBefore(expiry);
  }

  Future<void> clearAll() => _storage.deleteAll();
}