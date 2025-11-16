import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

/// Provider pour la gestion de l'authentification
///
/// Gère l'état de l'utilisateur connecté et expose les méthodes
/// d'authentification (inscription, connexion, déconnexion)
class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService);

  /// Utilisateur actuellement connecté
  User? get currentUser => _currentUser;

  /// Indique si une opération est en cours
  bool get isLoading => _isLoading;

  /// Message d'erreur de la dernière opération
  String? get errorMessage => _errorMessage;

  /// Indique si un utilisateur est connecté
  bool get isAuthenticated => _currentUser != null;

  /// Initialise le provider en chargeant l'utilisateur de la session
  Future<void> init() async {
    _currentUser = await _authService.getCurrentUser();
    notifyListeners();
  }

  /// Inscrit un nouvel utilisateur
  ///
  /// Retourne true en cas de succès, false en cas d'échec
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String gender,
  }) async {
    // Réinitialiser l'erreur
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Validation côté client
      if (!AuthService.isValidEmail(email)) {
        _errorMessage = 'Wrong email';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password != confirmPassword) {
        _errorMessage = 'The password and confirmation password do not match.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!AuthService.isValidPassword(password)) {
        _errorMessage = 'Password must be at least 6 characters.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Tenter l'inscription
      final user = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
      );

      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'This email is already registered.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Connecte un utilisateur
  ///
  /// Retourne true en cas de succès, false en cas d'échec
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // Réinitialiser l'erreur
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Login was unsuccessful. Please correct the errors and try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnecte l'utilisateur actuel
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Efface le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
