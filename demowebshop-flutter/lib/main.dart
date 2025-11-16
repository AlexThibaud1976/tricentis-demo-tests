import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Services
import 'services/auth_service.dart';
import 'services/database_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_confirmation_screen.dart';

// Config
import 'config/app_config.dart';

/// Point d'entrée principal de l'application
void main() async {
  // S'assurer que les bindings sont initialisés
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les services
  final authService = await AuthService.create();
  final dbService = DatabaseService.instance;

  runApp(DemoWebShopApp(
    authService: authService,
    dbService: dbService,
  ));
}

/// Application principale Demo Web Shop
///
/// Configure le thème, les providers et le routing de l'application
class DemoWebShopApp extends StatelessWidget {
  final AuthService authService;
  final DatabaseService dbService;

  const DemoWebShopApp({
    super.key,
    required this.authService,
    required this.dbService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider d'authentification
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService)..init(),
        ),
        // Provider de panier
        ChangeNotifierProvider(
          create: (_) => CartProvider(dbService),
        ),
        // Provider de produits
        ChangeNotifierProvider(
          create: (_) => ProductProvider(dbService),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,

        // Thème de l'application
        theme: ThemeData(
          primaryColor: const Color(AppConfig.primaryColor),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(AppConfig.primaryColor),
            secondary: const Color(AppConfig.accentColor),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(AppConfig.primaryColor),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConfig.primaryColor),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          useMaterial3: true,
        ),

        // Routes de l'application
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
        },

        // Gestionnaire de routes pour les routes avec arguments
        onGenerateRoute: (settings) {
          if (settings.name == '/order-confirmation') {
            final orderId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => OrderConfirmationScreen(orderId: orderId),
            );
          }
          return null;
        },

        // Page 404
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Page Not Found'),
              ),
              body: const Center(
                child: Text('404 - Page not found'),
              ),
            ),
          );
        },
      ),
    );
  }
}
