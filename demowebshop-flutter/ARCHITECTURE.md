# Architecture de l'Application Demo Web Shop

Ce document décrit l'architecture technique de l'application Demo Web Shop développée avec Flutter.

## 📐 Vue d'Ensemble

L'application suit une **architecture Clean** avec séparation claire des responsabilités :

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                    │
│  ┌────────────┐  ┌────────────┐  ┌────────────────────┐ │
│  │  Screens   │  │  Widgets   │  │  State Management  │ │
│  │            │  │            │  │    (Providers)     │ │
│  └────────────┘  └────────────┘  └────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    BUSINESS LAYER                        │
│  ┌────────────────────────────────────────────────────┐ │
│  │              Providers (State)                      │ │
│  │   • AuthProvider                                    │ │
│  │   • CartProvider                                    │ │
│  │   • ProductProvider                                 │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                          ▼
┌─────────────────────────────────────────────────────────┐
│                      DATA LAYER                          │
│  ┌────────────────┐         ┌────────────────────────┐  │
│  │   Services     │         │       Models           │  │
│  │ • AuthService  │         │ • User                 │  │
│  │ • DatabaseSrvc │         │ • Product              │  │
│  └────────────────┘         │ • CartItem             │  │
│                             │ • Order                │  │
│                             │ • Address              │  │
│                             └────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ▼
┌─────────────────────────────────────────────────────────┐
│                   PERSISTENCE LAYER                      │
│  ┌──────────────────┐       ┌──────────────────────┐   │
│  │  SQLite (DB)     │       │  SharedPreferences   │   │
│  │  • Products      │       │  • User Session      │   │
│  │  • Cart          │       │  • Auth Tokens       │   │
│  │  • Orders        │       │  • Preferences       │   │
│  │  • Addresses     │       │                      │   │
│  └──────────────────┘       └──────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## 🗂️ Structure des Dossiers

```
lib/
├── config/                     # Configuration de l'application
│   └── app_config.dart        # Constantes et paramètres globaux
│
├── models/                     # Modèles de données
│   ├── user.dart              # Modèle utilisateur
│   ├── product.dart           # Modèle produit
│   ├── cart_item.dart         # Modèle article du panier
│   ├── order.dart             # Modèle commande
│   └── address.dart           # Modèle adresse
│
├── providers/                  # State Management (Provider pattern)
│   ├── auth_provider.dart     # Gestion état authentification
│   ├── cart_provider.dart     # Gestion état panier
│   └── product_provider.dart  # Gestion état produits
│
├── screens/                    # Pages de l'application
│   ├── home_screen.dart       # Page d'accueil
│   ├── login_screen.dart      # Page de connexion
│   ├── register_screen.dart   # Page d'inscription
│   ├── cart_screen.dart       # Page du panier
│   ├── checkout_screen.dart   # Processus de commande
│   └── order_confirmation_screen.dart  # Confirmation
│
├── services/                   # Services métier
│   ├── auth_service.dart      # Service d'authentification
│   └── database_service.dart  # Service de base de données
│
├── utils/                      # Utilitaires et helpers
│   └── (à venir)
│
├── widgets/                    # Composants réutilisables
│   └── product_grid.dart      # Grille de produits
│
└── main.dart                   # Point d'entrée de l'app
```

## 🔄 Flux de Données

### 1. Flux d'Authentification

```
User Input (Screen)
    ↓
AuthProvider.login()
    ↓
AuthService.login()
    ↓
SharedPreferences (vérification)
    ↓
AuthProvider updates state
    ↓
UI rebuilds (notifyListeners)
```

### 2. Flux du Panier

```
Add to Cart Button
    ↓
CartProvider.addToCart()
    ↓
DatabaseService.addToCart()
    ↓
SQLite Database (insert)
    ↓
CartProvider updates local state
    ↓
UI shows updated cart count
```

### 3. Flux de Commande

```
Checkout Button
    ↓
CheckoutScreen (multi-step form)
    ↓
Order creation (CartProvider + AuthProvider)
    ↓
DatabaseService.createOrder()
    ↓
SQLite (insert order + items)
    ↓
CartProvider.clearCart()
    ↓
Navigate to confirmation
```

## 🎨 Patterns Utilisés

### 1. **Provider Pattern**
- Gestion d'état centralisée
- Séparation claire entre UI et logique métier
- Notification automatique des changements

```dart
// Dans le Provider
notifyListeners(); // Déclenche rebuild

// Dans le Widget
context.watch<CartProvider>(); // Écoute les changements
```

### 2. **Repository Pattern**
- Services (`AuthService`, `DatabaseService`) agissent comme repositories
- Abstraction de la source de données
- Facilite les tests et le changement de backend

### 3. **Singleton Pattern**
- `DatabaseService.instance` garantit une seule instance DB
- Évite les connexions multiples

### 4. **Factory Pattern**
- Méthodes `fromJson()` dans les modèles
- Construction d'objets à partir de données brutes

## 🔐 Sécurité

### Authentification
- **Stockage** : SharedPreferences (local)
- **Session** : Persistante jusqu'à déconnexion explicite
- **Validation** : Email regex, longueur mot de passe

⚠️ **Note** : Cette version utilise du stockage non chiffré à des fins de démonstration.
En production :
- Utiliser `flutter_secure_storage` pour les tokens
- Hasher les mots de passe (bcrypt/argon2)
- Implémenter JWT ou OAuth2

### Base de Données
- **SQLite** : Base locale pour les données
- **Transactions** : Support des transactions pour la cohérence
- **Validation** : Contraintes de clés étrangères

## 📱 Responsive Design

L'application s'adapte aux différentes tailles d'écran :

```dart
// Grille responsive
int getCrossAxisCount(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width > 1200) return 4;  // Desktop large
  if (width > 800) return 3;   // Desktop/Tablet
  if (width > 600) return 2;   // Tablet
  return 1;                     // Mobile
}
```

## 🧪 Testabilité

L'architecture facilite les tests :

### Unit Tests
```dart
test('Cart total calculation', () {
  final cart = CartProvider(mockDbService);
  // Test logic
});
```

### Widget Tests
```dart
testWidgets('Login form validation', (tester) async {
  await tester.pumpWidget(LoginScreen());
  // Test UI
});
```

### Integration Tests
```dart
testWidgets('Complete order flow', (tester) async {
  // Test end-to-end scenario
});
```

## 🚀 Performance

### Optimisations Implémentées

1. **Chargement paresseux** : Les produits sont chargés au démarrage
2. **Cache local** : SQLite cache les données
3. **State management efficient** : Provider minimise les rebuilds
4. **Images optimisées** : Support du lazy loading (à implémenter)

### Métriques Cibles

- **First Paint** : < 1s
- **Time to Interactive** : < 2s
- **Bundle Size (Web)** : < 5MB

## 🔄 État de l'Application

```dart
┌─────────────────────────────────────┐
│         App State Tree              │
├─────────────────────────────────────┤
│ AuthProvider                        │
│  ├─ currentUser: User?              │
│  ├─ isLoading: bool                 │
│  └─ errorMessage: String?           │
├─────────────────────────────────────┤
│ CartProvider                        │
│  ├─ items: List<CartItem>           │
│  ├─ isLoading: bool                 │
│  ├─ itemCount: int                  │
│  └─ subtotal: double                │
├─────────────────────────────────────┤
│ ProductProvider                     │
│  ├─ allProducts: List<Product>      │
│  ├─ filteredProducts: List<Product> │
│  ├─ selectedCategory: String?       │
│  └─ isLoading: bool                 │
└─────────────────────────────────────┘
```

## 🎯 Décisions d'Architecture

### Pourquoi Provider et pas BLoC ?
- **Simplicité** : Courbe d'apprentissage plus douce
- **Performance** : Suffisant pour cette app
- **Verbosité** : Moins de boilerplate
- **Écosystème** : Support officiel Flutter

### Pourquoi SQLite ?
- **Hors ligne** : Fonctionne sans réseau
- **Performance** : Rapide pour les requêtes locales
- **Portabilité** : Fonctionne sur toutes les plateformes
- **Maturité** : Bibliothèque éprouvée

### Pourquoi pas d'API Backend ?
- **Démo** : Application autonome
- **Simplicité** : Pas de serveur requis
- **Évolutivité** : Facile d'ajouter un backend plus tard

## 🔮 Évolutions Futures

### Court Terme
- [ ] Ajout de tests unitaires et d'intégration
- [ ] Amélioration du design UI/UX
- [ ] Support multilingue (i18n)
- [ ] Mode sombre

### Moyen Terme
- [ ] Backend API REST/GraphQL
- [ ] Synchronisation cloud
- [ ] Notifications push
- [ ] Analytics

### Long Terme
- [ ] Paiements réels (Stripe, PayPal)
- [ ] Système de reviews
- [ ] Wishlist et comparaison
- [ ] Recommandations IA

## 📚 Ressources

- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**Dernière mise à jour** : Novembre 2024
