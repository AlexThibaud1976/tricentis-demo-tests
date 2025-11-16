import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../config/app_config.dart';

/// Provider pour la gestion du panier d'achat
///
/// Gère l'état du panier et expose les méthodes pour
/// ajouter, modifier et supprimer des articles
class CartProvider with ChangeNotifier {
  final DatabaseService _dbService;
  final Uuid _uuid = const Uuid();

  List<CartItem> _items = [];
  bool _isLoading = false;

  CartProvider(this._dbService);

  /// Liste des articles du panier
  List<CartItem> get items => List.unmodifiable(_items);

  /// Indique si une opération est en cours
  bool get isLoading => _isLoading;

  /// Nombre total d'articles dans le panier
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Sous-total du panier (somme des prix × quantités)
  double get subtotal => _items.fold(
        0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

  /// Frais de livraison (calculés en fonction de la méthode sélectionnée)
  double getShippingCost(String method) {
    return AppConfig.shippingCosts[method] ?? 0.0;
  }

  /// Taxe (TVA)
  double get tax => subtotal * AppConfig.taxRate;

  /// Total du panier (sous-total + frais + taxe)
  double getTotal(String shippingMethod) {
    return subtotal + getShippingCost(shippingMethod) + tax;
  }

  /// Sous-total formaté
  String get formattedSubtotal => '€${subtotal.toStringAsFixed(2)}';

  /// Total formaté
  String getFormattedTotal(String shippingMethod) =>
      '€${getTotal(shippingMethod).toStringAsFixed(2)}';

  /// Indique si le panier est vide
  bool get isEmpty => _items.isEmpty;

  /// Charge les articles du panier depuis la base de données
  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _dbService.getCartItems();
    } catch (e) {
      debugPrint('Erreur lors du chargement du panier: $e');
      _items = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Ajoute un produit au panier
  ///
  /// Si le produit existe déjà, augmente sa quantité de 1
  Future<void> addToCart(Product product) async {
    try {
      // Vérifier si le produit est déjà dans le panier
      final existingIndex = _items.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex >= 0) {
        // Augmenter la quantité
        final existingItem = _items[existingIndex];
        final newQuantity = existingItem.quantity + 1;

        if (newQuantity <= AppConfig.maxCartQuantity) {
          await updateQuantity(existingItem.id, newQuantity);
        }
      } else {
        // Ajouter un nouvel article
        final newItem = CartItem(
          id: _uuid.v4(),
          product: product,
          quantity: 1,
          addedAt: DateTime.now(),
        );

        await _dbService.addToCart(newItem);
        _items.add(newItem);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout au panier: $e');
    }
  }

  /// Met à jour la quantité d'un article
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity < AppConfig.minCartQuantity ||
        newQuantity > AppConfig.maxCartQuantity) {
      return;
    }

    try {
      await _dbService.updateCartItemQuantity(cartItemId, newQuantity);

      final index = _items.indexWhere((item) => item.id == cartItemId);
      if (index >= 0) {
        _items[index] = _items[index].copyWith(quantity: newQuantity);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la quantité: $e');
    }
  }

  /// Supprime un article du panier
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _dbService.removeFromCart(cartItemId);
      _items.removeWhere((item) => item.id == cartItemId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la suppression du panier: $e');
    }
  }

  /// Vide complètement le panier
  Future<void> clearCart() async {
    try {
      await _dbService.clearCart();
      _items.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du vidage du panier: $e');
    }
  }

  /// Vérifie si un produit est dans le panier
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  /// Récupère la quantité d'un produit dans le panier
  int getProductQuantity(String productId) {
    try {
      final item = _items.firstWhere((item) => item.product.id == productId);
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }
}
