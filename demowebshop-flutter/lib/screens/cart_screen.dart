import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../config/app_config.dart';

/// Écran du panier d'achat
///
/// Affiche les articles du panier avec possibilité de modifier
/// les quantités, supprimer des articles et procéder au checkout
///
/// Labels Semantics ajoutés pour les tests Playwright:
/// - cart-item: Chaque article du panier
/// - product-name: Nom du produit
/// - unit-price: Prix unitaire
/// - subtotal: Sous-total de l'article
/// - quantity-input: Affichage de la quantité
/// - update-cart-button-minus: Bouton diminuer quantité
/// - update-cart-button-plus: Bouton augmenter quantité
/// - remove-checkbox: Bouton supprimer l'article
/// - terms-of-service: Checkbox des conditions de service
/// - checkout-button: Bouton de checkout
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping cart'),
      ),
      body: cartProvider.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // Liste des articles
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return Semantics(
                        label: 'cart-item',
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Image du produit
                                Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: item.product.imageUrl != null
                                      ? Image.network(
                                          item.product.imageUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.shopping_bag,
                                          size: 32,
                                          color: Colors.grey,
                                        ),
                                ),
                                const SizedBox(width: 16),

                                // Informations du produit
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Semantics(
                                        label: 'product-name',
                                        child: Text(
                                          item.product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Semantics(
                                        label: 'unit-price',
                                        child: Text(
                                          'Prix unitaire: ${item.product.formattedPrice}',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Semantics(
                                        label: 'subtotal',
                                        child: Text(
                                          'Sous-total: ${item.formattedSubtotal}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF5CAF90),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Contrôle de quantité
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Semantics(
                                          label: 'update-cart-button-minus',
                                          button: true,
                                          child: IconButton(
                                            onPressed: item.quantity > 1
                                                ? () => cartProvider.updateQuantity(
                                                      item.id,
                                                      item.quantity - 1,
                                                    )
                                                : null,
                                            icon: const Icon(Icons.remove),
                                            iconSize: 20,
                                          ),
                                        ),
                                        Semantics(
                                          label: 'quantity-input',
                                          child: Container(
                                            width: 40,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${item.quantity}',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Semantics(
                                          label: 'update-cart-button-plus',
                                          button: true,
                                          child: IconButton(
                                            onPressed: item.quantity <
                                                    AppConfig.maxCartQuantity
                                                ? () => cartProvider.updateQuantity(
                                                      item.id,
                                                      item.quantity + 1,
                                                    )
                                                : null,
                                            icon: const Icon(Icons.add),
                                            iconSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Semantics(
                                      label: 'remove-checkbox',
                                      button: true,
                                      child: TextButton.icon(
                                        onPressed: () =>
                                            cartProvider.removeFromCart(item.id),
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        label: const Text(
                                          'Supprimer',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Résumé et checkout
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Sous-total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sous-total:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            cartProvider.formattedSubtotal,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Conditions de service
                      Row(
                        children: [
                          Semantics(
                            label: 'terms-of-service',
                            child: Checkbox(
                              value: _termsAccepted,
                              onChanged: (value) {
                                setState(() => _termsAccepted = value ?? false);
                              },
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'I agree with the terms of service',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Bouton Checkout
                      Semantics(
                        label: 'checkout-button',
                        button: true,
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _termsAccepted
                                ? () {
                                    if (!authProvider.isAuthenticated) {
                                      // Demander de se connecter
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Login Required'),
                                          content: const Text(
                                            'Please log in to continue with checkout.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.pushNamed(
                                                  context,
                                                  '/login',
                                                );
                                              },
                                              child: const Text('Log in'),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      Navigator.pushNamed(context, '/checkout');
                                    }
                                  }
                                : () {
                                    // Montrer une alerte
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Terms of Service'),
                                        content: const Text(
                                          'Please agree to the terms of service to continue.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5CAF90),
                            ),
                            child: const Text(
                              'Checkout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  /// Widget affiché quand le panier est vide
  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Your Shopping Cart is empty!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some products to your cart',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
