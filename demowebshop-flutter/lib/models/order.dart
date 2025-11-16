import 'address.dart';
import 'cart_item.dart';

/// Énumération des statuts possibles d'une commande
enum OrderStatus {
  pending,      // En attente
  processing,   // En cours de traitement
  shipped,      // Expédiée
  delivered,    // Livrée
  cancelled,    // Annulée
}

/// Énumération des méthodes de paiement
enum PaymentMethod {
  cashOnDelivery,  // Paiement à la livraison
  creditCard,      // Carte de crédit
  paypal,          // PayPal
}

/// Énumération des méthodes de livraison
enum ShippingMethod {
  ground,          // Livraison standard
  nextDayAir,      // Livraison express 24h
  secondDayAir,    // Livraison express 48h
}

/// Modèle représentant une commande complète
///
/// Contient tous les détails d'une commande : articles, adresses,
/// méthodes de paiement et livraison, totaux, etc.
class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final Address billingAddress;
  final Address shippingAddress;
  final PaymentMethod paymentMethod;
  final ShippingMethod shippingMethod;
  final OrderStatus status;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double total;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  /// Constructeur du modèle Order
  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.billingAddress,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.status,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.total,
    required this.createdAt,
    this.deliveredAt,
  });

  /// Crée une commande à partir d'une Map (désérialisation)
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      billingAddress: Address.fromJson(json['billingAddress'] as Map<String, dynamic>),
      shippingAddress: Address.fromJson(json['shippingAddress'] as Map<String, dynamic>),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${json['paymentMethod']}',
      ),
      shippingMethod: ShippingMethod.values.firstWhere(
        (e) => e.toString() == 'ShippingMethod.${json['shippingMethod']}',
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
      ),
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingCost: (json['shippingCost'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
    );
  }

  /// Convertit la commande en Map (sérialisation)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'billingAddress': billingAddress.toJson(),
      'shippingAddress': shippingAddress.toJson(),
      'paymentMethod': paymentMethod.toString().split('.').last,
      'shippingMethod': shippingMethod.toString().split('.').last,
      'status': status.toString().split('.').last,
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'tax': tax,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  /// Retourne le nombre total d'articles dans la commande
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Retourne le total formaté avec symbole monétaire
  String get formattedTotal => '€${total.toStringAsFixed(2)}';

  /// Retourne le sous-total formaté
  String get formattedSubtotal => '€${subtotal.toStringAsFixed(2)}';

  /// Retourne les frais de livraison formatés
  String get formattedShippingCost => '€${shippingCost.toStringAsFixed(2)}';

  /// Retourne la taxe formatée
  String get formattedTax => '€${tax.toStringAsFixed(2)}';

  /// Crée une copie de la commande avec des champs modifiés
  Order copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    Address? billingAddress,
    Address? shippingAddress,
    PaymentMethod? paymentMethod,
    ShippingMethod? shippingMethod,
    OrderStatus? status,
    double? subtotal,
    double? shippingCost,
    double? tax,
    double? total,
    DateTime? createdAt,
    DateTime? deliveredAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Order{id: $id, items: ${items.length}, total: $formattedTotal, status: $status}';
}
