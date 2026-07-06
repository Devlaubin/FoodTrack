import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:foodtruck_app/domain/user_profile.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase;

  User? _user;
  UserProfile? _profile;
  bool _isLoading = true;
  String? _error;

  AuthService(this._supabase) {
    _init();
  }

  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;
  UserRole get userRole => _profile?.role ?? UserRole.client;

  Future<void> _init() async {
    _user = _supabase.auth.currentUser;

    if (_user != null) {
      await _loadProfile();
    }

    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      _user = data.session?.user;

      if (event == AuthChangeEvent.signedIn && _user != null) {
        _loadProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        _profile = null;
      }

      notifyListeners();
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    if (_user == null) return;

    try {
      // Retry logic for profile loading (in case trigger is delayed)
      int retries = 0;
      const maxRetries = 3;
      const retryDelay = Duration(milliseconds: 500);

      while (retries < maxRetries) {
        try {
          final response = await _supabase
              .from('profiles')
              .select()
              .eq('id', _user!.id)
              .maybeSingle()
              .timeout(const Duration(seconds: 5));

          if (response != null) {
            _profile = UserProfile.fromJson(response);
            return;
          }

          // Profile not found yet, retry after delay
          retries++;
          if (retries < maxRetries) {
            await Future.delayed(retryDelay);
          }
        } on TimeoutException {
          retries++;
          if (retries < maxRetries) {
            await Future.delayed(retryDelay);
          } else {
            debugPrint('Timeout loading profile after $maxRetries retries');
            rethrow;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required UserRole role,
    String? displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.auth
          .signUp(
            email: email,
            password: password,
            data: {
              'role': role == UserRole.pro ? 'pro' : 'client',
              if (displayName != null) 'display_name': displayName,
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException(
              'Inscription prend trop de temps. Vérifiez votre connexion.',
            ),
          );

      if (response.user != null) {
        _user = response.user;
        await _loadProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on TimeoutException catch (e) {
      _error = e.message ?? 'La demande a pris trop de temps. Réessayez.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _error = _getErrorMessage(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Une erreur est survenue. Veuillez réessayer.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.auth
          .signInWithPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException(
              'Connexion prend trop de temps. Vérifiez votre connexion.',
            ),
          );

      if (response.user != null) {
        _user = response.user;
        await _loadProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on TimeoutException catch (e) {
      _error = e.message ?? 'La demande a pris trop de temps. Réessayez.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _error = _getErrorMessage(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Une erreur est survenue. Veuillez réessayer.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _supabase.auth.signOut();
    _user = null;
    _profile = null;

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(String message) {
    if (message.contains('invalid_credentials') ||
        message.contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect.';
    }
    if (message.contains('email_not confirmed')) {
      return 'Veuillez confirmer votre email.';
    }
    if (message.contains('user_already_exists') ||
        message.contains('User already registered')) {
      return 'Un compte existe déjà avec cet email.';
    }
    if (message.contains('weak_password')) {
      return 'Le mot de passe est trop faible (minimum 6 caractères).';
    }
    if (message.contains('invalid_email')) {
      return 'Format d\'email invalide.';
    }
    return message;
  }
}
