import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_grid.dart';
import '../config/app_config.dart';

/// Écran d'accueil de l'application
///
/// Affiche les catégories de produits, une barre de recherche
/// et la liste des produits disponibles
///
/// Labels Semantics ajoutés pour les tests Playwright:
/// - ico-login: Bouton de connexion
/// - ico-logout: Lien de déconnexion
/// - ico-cart: Bouton panier
/// - ico-register: Bouton d'inscription
/// - search-input: Champ de recherche
/// - search-button: Bouton de recherche
/// - user-email: Email de l'utilisateur connecté
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Charger les produits au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          // Bouton de connexion/compte
          if (!authProvider.isAuthenticated)
            Semantics(
              label: 'ico-login',
              link: true,
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text(
                  'Log in',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          else
            PopupMenuButton(
              icon: const Icon(Icons.account_circle),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Semantics(
                    label: 'user-email',
                    child: Text(
                      authProvider.currentUser?.email ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: Semantics(
                    label: 'ico-logout',
                    link: true,
                    child: const Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Log out'),
                      ],
                    ),
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'logout') {
                  authProvider.logout();
                }
              },
            ),

          // Bouton panier avec compteur
          Semantics(
            label: 'ico-cart',
            button: true,
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                  icon: const Icon(Icons.shopping_cart),
                ),
                if (cartProvider.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cartProvider.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'search-input',
                    textField: true,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.length >= AppConfig.searchMinLength) {
                          productProvider.searchProducts(value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: 'search-button',
                  button: true,
                  child: ElevatedButton(
                    onPressed: () {
                      final query = _searchController.text;
                      if (query.length >= AppConfig.searchMinLength) {
                        productProvider.searchProducts(query);
                      }
                    },
                    child: const Text('Search'),
                  ),
                ),
              ],
            ),
          ),

          // Menu des catégories
          Container(
            height: 50,
            color: const Color(0xFF4B7289),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryButton(context, null, 'All'),
                ...AppConfig.categories.map(
                  (category) => _buildCategoryButton(context, category, category),
                ),
              ],
            ),
          ),

          // Liste des produits
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.products.isEmpty
                    ? const Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ProductGrid(products: productProvider.products),
          ),
        ],
      ),
      floatingActionButton: !authProvider.isAuthenticated
          ? Semantics(
              label: 'ico-register',
              button: true,
              child: FloatingActionButton.extended(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                icon: const Icon(Icons.person_add),
                label: const Text('Register'),
              ),
            )
          : null,
    );
  }

  /// Construit un bouton de catégorie
  Widget _buildCategoryButton(
    BuildContext context,
    String? category,
    String label,
  ) {
    final productProvider = context.watch<ProductProvider>();
    final isSelected = productProvider.selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () => productProvider.filterByCategory(category),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? Colors.white.withOpacity(0.2) : null,
          foregroundColor: Colors.white,
        ),
        child: Text(label),
      ),
    );
  }
}
