import 'product.dart';

/// Modèle représentant un article dans le panier d'achat
///
/// Associe un produit à une quantité et permet de calculer
/// le sous-total pour cet article
class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final DateTime addedAt;

  /// Constructeur du modèle CartItem
  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  /// Crée un CartItem à partir d'une Map (désérialisation)
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  /// Convertit le CartItem en Map (sérialisation)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// Calcule le sous-total pour cet article (prix × quantité)
  double get subtotal => product.price * quantity;

  /// Retourne le sous-total formaté avec symbole monétaire
  String get formattedSubtotal => '€${subtotal.toStringAsFixed(2)}';

  /// Crée une copie du CartItem avec des champs modifiés
  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CartItem{product: ${product.name}, quantity: $quantity, subtotal: $formattedSubtotal}';
}
