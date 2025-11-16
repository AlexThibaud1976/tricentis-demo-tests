import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

/// Service de gestion de l'authentification
///
/// Gère l'inscription, la connexion, la déconnexion et la persistance
/// de la session utilisateur via SharedPreferences
class AuthService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';
  static const String _passwordsKey = 'user_passwords';

  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  AuthService(this._prefs);

  /// Factory pour créer une instance du service
  static Future<AuthService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthService(prefs);
  }

  /// Inscrit un nouvel utilisateur
  ///
  /// Vérifie que l'email n'est pas déjà utilisé, crée le compte
  /// et enregistre les informations de manière sécurisée
  ///
  /// Retourne le nouvel utilisateur en cas de succès, null en cas d'erreur
  Future<User?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
  }) async {
    try {
      // Vérifier si l'email existe déjà
      final existingUser = await _getUserByEmail(email);
      if (existingUser != null) {
        return null; // Email déjà utilisé
      }

      // Créer le nouvel utilisateur
      final user = User(
        id: _uuid.v4(),
        email: email.toLowerCase().trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        gender: gender,
        createdAt: DateTime.now(),
      );

      // Sauvegarder l'utilisateur
      await _saveUser(user, password);

      // Connecter automatiquement l'utilisateur
      await _setCurrentUser(user);

      return user;
    } catch (e) {
      return null;
    }
  }

  /// Connecte un utilisateur existant
  ///
  /// Vérifie les identifiants et établit la session si valides
  ///
  /// Retourne l'utilisateur en cas de succès, null si les identifiants sont invalides
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Récupérer l'utilisateur par email
      final user = await _getUserByEmail(email.toLowerCase().trim());
      if (user == null) {
        return null; // Utilisateur non trouvé
      }

      // Vérifier le mot de passe
      if (!await _verifyPassword(user.id, password)) {
        return null; // Mot de passe incorrect
      }

      // Établir la session
      await _setCurrentUser(user);

      return user;
    } catch (e) {
      return null;
    }
  }

  /// Déconnecte l'utilisateur actuel
  Future<void> logout() async {
    await _prefs.remove(_currentUserKey);
  }

  /// Récupère l'utilisateur actuellement connecté
  ///
  /// Retourne l'utilisateur connecté ou null si aucune session active
  Future<User?> getCurrentUser() async {
    final userJson = _prefs.getString(_currentUserKey);
    if (userJson == null) return null;

    try {
      final Map<String, dynamic> userData = json.decode(userJson);
      return User.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si un utilisateur est actuellement connecté
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Sauvegarde un utilisateur dans la liste des utilisateurs enregistrés
  Future<void> _saveUser(User user, String password) async {
    // Récupérer la liste des utilisateurs
    final users = await _getAllUsers();

    // Ajouter le nouvel utilisateur
    users[user.id] = user;

    // Sauvegarder
    final usersMap = users.map((key, value) => MapEntry(key, value.toJson()));
    await _prefs.setString(_usersKey, json.encode(usersMap));

    // Sauvegarder le mot de passe (dans une vraie app, il faudrait le hasher)
    await _savePassword(user.id, password);
  }

  /// Récupère tous les utilisateurs enregistrés
  Future<Map<String, User>> _getAllUsers() async {
    final usersJson = _prefs.getString(_usersKey);
    if (usersJson == null) return {};

    try {
      final Map<String, dynamic> usersMap = json.decode(usersJson);
      return usersMap.map((key, value) {
        return MapEntry(key, User.fromJson(value as Map<String, dynamic>));
      });
    } catch (e) {
      return {};
    }
  }

  /// Récupère un utilisateur par son email
  Future<User?> _getUserByEmail(String email) async {
    final users = await _getAllUsers();
    try {
      return users.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  /// Définit l'utilisateur actuellement connecté
  Future<void> _setCurrentUser(User user) async {
    await _prefs.setString(_currentUserKey, json.encode(user.toJson()));
  }

  /// Sauvegarde le mot de passe d'un utilisateur
  ///
  /// Note: Dans une application de production, les mots de passe doivent être hashés
  /// avec un algorithme sécurisé (bcrypt, argon2, etc.)
  Future<void> _savePassword(String userId, String password) async {
    final passwords = await _getAllPasswords();
    passwords[userId] = password; // En production: hasher le mot de passe
    await _prefs.setString(_passwordsKey, json.encode(passwords));
  }

  /// Récupère tous les mots de passe
  Future<Map<String, String>> _getAllPasswords() async {
    final passwordsJson = _prefs.getString(_passwordsKey);
    if (passwordsJson == null) return {};

    try {
      final Map<String, dynamic> passwordsMap = json.decode(passwordsJson);
      return passwordsMap.map((key, value) => MapEntry(key, value as String));
    } catch (e) {
      return {};
    }
  }

  /// Vérifie si un mot de passe est correct pour un utilisateur
  Future<bool> _verifyPassword(String userId, String password) async {
    final passwords = await _getAllPasswords();
    final storedPassword = passwords[userId];

    // En production: comparer avec le hash
    return storedPassword == password;
  }

  /// Valide un email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Valide un mot de passe
  ///
  /// Règles: minimum 6 caractères
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}
