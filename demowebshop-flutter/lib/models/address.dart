/// Modèle représentant une adresse (facturation ou livraison)
///
/// Contient toutes les informations nécessaires pour une adresse
/// dans le processus de commande
class Address {
  final String id;
  final String country;
  final String city;
  final String address1;
  final String? address2;
  final String zipCode;
  final String phoneNumber;
  final bool isDefault;

  /// Constructeur du modèle Address
  const Address({
    required this.id,
    required this.country,
    required this.city,
    required this.address1,
    this.address2,
    required this.zipCode,
    required this.phoneNumber,
    this.isDefault = false,
  });

  /// Crée une adresse à partir d'une Map (désérialisation)
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      country: json['country'] as String,
      city: json['city'] as String,
      address1: json['address1'] as String,
      address2: json['address2'] as String?,
      zipCode: json['zipCode'] as String,
      phoneNumber: json['phoneNumber'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  /// Convertit l'adresse en Map (sérialisation)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'city': city,
      'address1': address1,
      'address2': address2,
      'zipCode': zipCode,
      'phoneNumber': phoneNumber,
      'isDefault': isDefault,
    };
  }

  /// Retourne l'adresse complète formatée
  String get formattedAddress {
    final buffer = StringBuffer(address1);
    if (address2 != null && address2!.isNotEmpty) {
      buffer.write('\n$address2');
    }
    buffer.write('\n$zipCode $city');
    buffer.write('\n$country');
    return buffer.toString();
  }

  /// Crée une copie de l'adresse avec des champs modifiés
  Address copyWith({
    String? id,
    String? country,
    String? city,
    String? address1,
    String? address2,
    String? zipCode,
    String? phoneNumber,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      country: country ?? this.country,
      city: city ?? this.city,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      zipCode: zipCode ?? this.zipCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Address{city: $city, country: $country}';
}
