import 'dart:async';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/address.dart';

/// Service de gestion de la base de données SQLite
///
/// Gère la création, la mise à jour et les opérations CRUD
/// sur toutes les tables de l'application
/// Utilise sqflite_common_ffi_web pour la compatibilité web
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  /// Getter pour accéder à la base de données
  /// Crée la base si elle n'existe pas encore
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('demowebshop.db');
    return _database!;
  }

  /// Initialise la base de données
  Future<Database> _initDB(String filePath) async {
    // Pour le web, utiliser directement le factory FFI Web
    final factory = databaseFactoryFfiWeb;

    // Pour le web, on utilise juste le nom du fichier
    final path = filePath;

    return await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
  }

  /// Crée toutes les tables de la base de données
  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    // Table des produits
    await db.execute('''
      CREATE TABLE products (
        id $idType,
        name $textType,
        description $textType,
        price $doubleType,
        category $textType,
        imageUrl $textTypeNullable,
        isAvailable $boolType,
        createdAt $textType
      )
    ''');

    // Table du panier
    await db.execute('''
      CREATE TABLE cart_items (
        id $idType,
        productId $textType,
        quantity $intType,
        addedAt $textType,
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');

    // Table des adresses
    await db.execute('''
      CREATE TABLE addresses (
        id $idType,
        userId $textType,
        country $textType,
        city $textType,
        address1 $textType,
        address2 $textTypeNullable,
        zipCode $textType,
        phoneNumber $textType,
        isDefault $boolType
      )
    ''');

    // Table des commandes
    await db.execute('''
      CREATE TABLE orders (
        id $idType,
        userId $textType,
        billingAddressId $textType,
        shippingAddressId $textType,
        paymentMethod $textType,
        shippingMethod $textType,
        status $textType,
        subtotal $doubleType,
        shippingCost $doubleType,
        tax $doubleType,
        total $doubleType,
        createdAt $textType,
        deliveredAt $textTypeNullable
      )
    ''');

    // Table des articles de commande
    await db.execute('''
      CREATE TABLE order_items (
        id $idType,
        orderId $textType,
        productId $textType,
        quantity $intType,
        price $doubleType,
        FOREIGN KEY (orderId) REFERENCES orders (id),
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');

    // Insérer des données de démonstration
    await _insertDemoData(db);
  }

  /// Insère des données de démonstration
  Future<void> _insertDemoData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Produits de la catégorie Books
    final books = [
      {
        'id': 'book-1',
        'name': 'Fiction',
        'description': 'A compelling work of fiction that will keep you engaged from start to finish.',
        'price': 24.0,
        'category': 'Books',
        'imageUrl': null,
        'isAvailable': 1,
        'createdAt': now,
      },
      {
        'id': 'book-2',
        'name': 'Computing and Internet',
        'description': 'Essential guide to modern computing and internet technologies.',
        'price': 10.0,
        'category': 'Books',
        'imageUrl': null,
        'isAvailable': 1,
        'createdAt': now,
      },
      {
        'id': 'book-3',
        'name': 'Health Book',
        'description': 'Your comprehensive guide to maintaining a healthy lifestyle.',
        'price': 10.0,
        'category': 'Books',
        'imageUrl': null,
        'isAvailable': 1,
        'createdAt': now,
      },
    ];

    // Produits de la catégorie Computers
    final computers = [
      {
        'id': 'comp-1',
        'name': 'Build your own computer',
        'description': 'Complete kit to build your custom PC. Intel Core i7, 16GB RAM, 1TB SSD.',
        'price': 1200.0,
        'category': 'Computers',
        'imageUrl': null,
        'isAvailable': 1,
        'createdAt': now,
      },
      {
        'id': 'comp-2',
        'name': 'Laptop Computer',
        'description': 'High-performance laptop. 15.6" display, Intel i5, 8GB RAM, 512GB SSD.',
        'price': 1590.0,
        'category': 'Computers',
        'imageUrl': null,
        'isAvailable': 1,
        'createdAt': now,
      },
      {
        'id': 'comp-3',
        'name': 'Desktop Computer',
        'description': 'Powerful desktop computer for professional use.',
        'price': 899.0,
        'category': 'Computers',
        'imageUrl': null,
        'isAvailable': 1,
        'createdAt': now,
      },
    ];

    // Produits de la catégorie Electronics
    final electronics = [
      {
        'id': 'elec-1',
        'name': 'Camera & photo',
        'description': 'Professional digital camera with 24MP sensor and 4K video.',
        'price': 670.0,
        'category': 'Electronics',
        'imageUrl': null,
        'isAvailable': 1,
        'createdAt': now,
      },
      {
        'id': 'elec-2',
        'name': 'Cell phones',
        'description': 'Latest smartphone with advanced features and 5G connectivity.',
        'price': 100.0,
        'category': 'Electronics',
        'imageUrl': null,
        'isAvailable': 1,
        'createdAt': now,
      },
    ];

    // Insérer tous les produits
    for (final product in [...books, ...computers, ...electronics]) {
      await db.insert('products', product);
    }
  }

  /// Ferme la base de données
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  // === Méthodes CRUD pour les produits ===

  /// Récupère tous les produits
  Future<List<Product>> getProducts() async {
    final db = await instance.database;
    final result = await db.query('products', orderBy: 'name ASC');
    return result.map((json) => Product.fromJson(json)).toList();
  }

  /// Récupère les produits par catégorie
  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
    return result.map((json) => Product.fromJson(json)).toList();
  }

  /// Recherche des produits par nom
  Future<List<Product>> searchProducts(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'products',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((json) => Product.fromJson(json)).toList();
  }

  /// Récupère un produit par son ID
  Future<Product?> getProductById(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Product.fromJson(result.first);
    }
    return null;
  }

  // === Méthodes pour le panier ===

  /// Ajoute un article au panier
  Future<void> addToCart(CartItem item) async {
    final db = await instance.database;
    await db.insert(
      'cart_items',
      {
        'id': item.id,
        'productId': item.product.id,
        'quantity': item.quantity,
        'addedAt': item.addedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère tous les articles du panier
  Future<List<CartItem>> getCartItems() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT
        ci.id as cart_id,
        ci.quantity,
        ci.addedAt,
        p.*
      FROM cart_items ci
      INNER JOIN products p ON ci.productId = p.id
      ORDER BY ci.addedAt DESC
    ''');

    return result.map((row) {
      final product = Product(
        id: row['id'] as String,
        name: row['name'] as String,
        description: row['description'] as String,
        price: (row['price'] as num).toDouble(),
        category: row['category'] as String,
        imageUrl: row['imageUrl'] as String?,
        isAvailable: (row['isAvailable'] as int) == 1,
        createdAt: DateTime.parse(row['createdAt'] as String),
      );

      return CartItem(
        id: row['cart_id'] as String,
        product: product,
        quantity: row['quantity'] as int,
        addedAt: DateTime.parse(row['addedAt'] as String),
      );
    }).toList();
  }

  /// Met à jour la quantité d'un article du panier
  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    final db = await instance.database;
    await db.update(
      'cart_items',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
  }

  /// Supprime un article du panier
  Future<void> removeFromCart(String cartItemId) async {
    final db = await instance.database;
    await db.delete(
      'cart_items',
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
  }

  /// Vide complètement le panier
  Future<void> clearCart() async {
    final db = await instance.database;
    await db.delete('cart_items');
  }

  // === Méthodes pour les adresses ===

  /// Sauvegarde une adresse
  Future<void> saveAddress(Address address, String userId) async {
    final db = await instance.database;
    await db.insert(
      'addresses',
      {
        'id': address.id,
        'userId': userId,
        'country': address.country,
        'city': address.city,
        'address1': address.address1,
        'address2': address.address2,
        'zipCode': address.zipCode,
        'phoneNumber': address.phoneNumber,
        'isDefault': address.isDefault ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère les adresses d'un utilisateur
  Future<List<Address>> getAddresses(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'addresses',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((json) {
      return Address(
        id: json['id'] as String,
        country: json['country'] as String,
        city: json['city'] as String,
        address1: json['address1'] as String,
        address2: json['address2'] as String?,
        zipCode: json['zipCode'] as String,
        phoneNumber: json['phoneNumber'] as String,
        isDefault: (json['isDefault'] as int) == 1,
      );
    }).toList();
  }

  // === Méthodes pour les commandes ===

  /// Crée une nouvelle commande
  Future<void> createOrder(Order order) async {
    final db = await instance.database;

    // Insérer les adresses si nécessaire
    await saveAddress(order.billingAddress, order.userId);
    await saveAddress(order.shippingAddress, order.userId);

    // Insérer la commande
    await db.insert('orders', {
      'id': order.id,
      'userId': order.userId,
      'billingAddressId': order.billingAddress.id,
      'shippingAddressId': order.shippingAddress.id,
      'paymentMethod': order.paymentMethod.toString().split('.').last,
      'shippingMethod': order.shippingMethod.toString().split('.').last,
      'status': order.status.toString().split('.').last,
      'subtotal': order.subtotal,
      'shippingCost': order.shippingCost,
      'tax': order.tax,
      'total': order.total,
      'createdAt': order.createdAt.toIso8601String(),
      'deliveredAt': order.deliveredAt?.toIso8601String(),
    });

    // Insérer les articles de la commande
    for (final item in order.items) {
      await db.insert('order_items', {
        'id': '${order.id}-${item.product.id}',
        'orderId': order.id,
        'productId': item.product.id,
        'quantity': item.quantity,
        'price': item.product.price,
      });
    }
  }

  /// Récupère les commandes d'un utilisateur
  Future<List<Order>> getOrders(String userId) async {
    final db = await instance.database;
    final ordersResult = await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    final orders = <Order>[];
    for (final orderRow in ordersResult) {
      final orderId = orderRow['id'] as String;

      // Récupérer les articles de la commande
      final itemsResult = await db.rawQuery('''
        SELECT
          oi.id,
          oi.quantity,
          p.*
        FROM order_items oi
        INNER JOIN products p ON oi.productId = p.id
        WHERE oi.orderId = ?
      ''', [orderId]);

      final items = itemsResult.map((row) {
        final product = Product.fromJson(row);
        return CartItem(
          id: row['id'] as String,
          product: product,
          quantity: row['quantity'] as int,
          addedAt: DateTime.parse(orderRow['createdAt'] as String),
        );
      }).toList();

      // Récupérer les adresses
      final billingAddress = await _getAddressById(orderRow['billingAddressId'] as String);
      final shippingAddress = await _getAddressById(orderRow['shippingAddressId'] as String);

      if (billingAddress != null && shippingAddress != null) {
        orders.add(Order(
          id: orderId,
          userId: orderRow['userId'] as String,
          items: items,
          billingAddress: billingAddress,
          shippingAddress: shippingAddress,
          paymentMethod: PaymentMethod.values.firstWhere(
            (e) => e.toString() == 'PaymentMethod.${orderRow['paymentMethod']}',
          ),
          shippingMethod: ShippingMethod.values.firstWhere(
            (e) => e.toString() == 'ShippingMethod.${orderRow['shippingMethod']}',
          ),
          status: OrderStatus.values.firstWhere(
            (e) => e.toString() == 'OrderStatus.${orderRow['status']}',
          ),
          subtotal: (orderRow['subtotal'] as num).toDouble(),
          shippingCost: (orderRow['shippingCost'] as num).toDouble(),
          tax: (orderRow['tax'] as num).toDouble(),
          total: (orderRow['total'] as num).toDouble(),
          createdAt: DateTime.parse(orderRow['createdAt'] as String),
          deliveredAt: orderRow['deliveredAt'] != null
              ? DateTime.parse(orderRow['deliveredAt'] as String)
              : null,
        ));
      }
    }

    return orders;
  }

  /// Récupère une adresse par son ID
  Future<Address?> _getAddressById(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'addresses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;

    final json = result.first;
    return Address(
      id: json['id'] as String,
      country: json['country'] as String,
      city: json['city'] as String,
      address1: json['address1'] as String,
      address2: json['address2'] as String?,
      zipCode: json['zipCode'] as String,
      phoneNumber: json['phoneNumber'] as String,
      isDefault: (json['isDefault'] as int) == 1,
    );
  }
}
