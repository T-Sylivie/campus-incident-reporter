import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  StreamSubscription<User?>? _sub;

  User? _firebaseUser;
  AppUser? _profile;
  bool _initializing = true;
  bool _busy = false;
  String? _error;

  AuthProvider(this._service) {
    _sub = _service.authStateChanges().listen(_onAuthChanged);
  }

  bool get initializing => _initializing;
  bool get busy => _busy;
  String? get error => _error;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isVerified => _service.currentUser?.emailVerified ?? false;
  AppUser? get profile => _profile;
  bool get isStaff => _profile?.isStaff ?? false;

  Future<void> _onAuthChanged(User? user) async {
    _firebaseUser = user;
    if (user == null) {
      _profile = null;
    } else {
      // During registration the profile document may not exist yet;
      // keep any profile we already have instead of wiping it.
      final fetched = await _service.fetchProfile(user.uid);
      _profile = fetched ?? _profile;
    }
    _initializing = false;
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) =>
      _run(() async {
        final user = await _service.register(
            name: name, email: email, password: password);
        _firebaseUser = user;
        _profile = await _service.fetchProfile(user.uid);
      });

  Future<bool> login(String email, String password) =>
      _run(() => _service.login(email, password));

  Future<void> logout() => _service.logout();

  Future<void> resendVerification() => _run(_service.resendVerification);

  Future<bool> checkVerified() async {
    final verified = await _service.refreshVerified();
    final user = _service.currentUser;
    if (user != null && _profile == null) {
      _profile = await _service.fetchProfile(user.uid);
    }
    notifyListeners();
    return verified;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendly(e);
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  String _friendly(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}