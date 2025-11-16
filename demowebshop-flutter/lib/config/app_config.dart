/// Configuration de l'application
///
/// Contient toutes les constantes et configurations nécessaires
/// pour l'application Demo Web Shop
class AppConfig {
  // Informations de l'application
  static const String appName = 'Demo Web Shop';
  static const String appVersion = '1.0.0';

  // Catégories de produits disponibles
  static const List<String> categories = [
    'Books',
    'Computers',
    'Electronics',
    'Apparel & Shoes',
    'Digital downloads',
    'Jewelry',
    'Gift Cards',
  ];

  // Pays disponibles pour l'adresse
  static const List<String> countries = [
    'France',
    'United States',
    'Canada',
    'United Kingdom',
    'Germany',
    'Spain',
    'Italy',
    'Belgium',
    'Switzerland',
  ];

  // Configuration de la TVA
  static const double taxRate = 0.20; // 20% TVA

  // Frais de livraison par méthode
  static const Map<String, double> shippingCosts = {
    'ground': 0.0,        // Gratuit
    'nextDayAir': 15.0,   // 15€
    'secondDayAir': 10.0, // 10€
  };

  // Limites
  static const int maxCartQuantity = 99;
  static const int minCartQuantity = 1;
  static const int searchMinLength = 2;

  // URLs et endpoints (pour une future API)
  static const String apiBaseUrl = 'https://api.demowebshop.com';

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration sessionTimeout = Duration(hours: 24);

  // Paramètres de pagination
  static const int productsPerPage = 12;

  // Messages d'erreur
  static const String errorEmailInvalid = 'Wrong email';
  static const String errorPasswordMismatch = 'The password and confirmation password do not match.';
  static const String errorLoginFailed = 'Login was unsuccessful. Please correct the errors and try again.';
  static const String errorRegistrationFailed = 'Registration failed. Please try again.';
  static const String errorEmailExists = 'This email is already registered.';
  static const String errorEmptyCart = 'Your Shopping Cart is empty!';
  static const String errorNetworkFailed = 'Network error. Please check your connection.';

  // Messages de succès
  static const String successRegistration = 'Your registration completed';
  static const String successOrderPlaced = 'Your order has been successfully processed!';
  static const String successProductAdded = 'The product has been added to your shopping cart';

  // Valeurs par défaut
  static const String defaultCurrency = '€';
  static const String defaultLanguage = 'fr';

  // Thème de couleurs (pour référence)
  static const int primaryColor = 0xFF4B7289; // Bleu-gris
  static const int accentColor = 0xFF5CAF90;  // Vert
  static const int errorColor = 0xFFE74C3C;   // Rouge

  /// Constructeur privé pour empêcher l'instanciation
  AppConfig._();
}
