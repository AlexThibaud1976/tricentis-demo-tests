/// Modèle représentant un utilisateur de l'application
///
/// Ce modèle contient toutes les informations nécessaires pour l'authentification
/// et la gestion du profil utilisateur
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final DateTime createdAt;

  /// Constructeur du modèle User
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.createdAt,
  });

  /// Crée un utilisateur à partir d'une Map (utilisé pour la désérialisation)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      gender: json['gender'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convertit l'utilisateur en Map (utilisé pour la sérialisation)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Retourne le nom complet de l'utilisateur
  String get fullName => '$firstName $lastName';

  /// Crée une copie de l'utilisateur avec des champs modifiés
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'User{id: $id, email: $email, name: $fullName, gender: $gender}';
}
