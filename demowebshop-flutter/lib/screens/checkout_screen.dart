import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../config/app_config.dart';

/// Écran de processus de checkout
///
/// Guide l'utilisateur à travers les étapes de commande :
/// adresse de facturation, livraison, paiement, confirmation
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  int _currentStep = 0;

  // Contrôleurs pour l'adresse de facturation
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _phoneController = TextEditingController();

  // Méthodes de livraison et paiement
  ShippingMethod _shippingMethod = ShippingMethod.ground;
  PaymentMethod _paymentMethod = PaymentMethod.cashOnDelivery;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _countryController.text = 'France';
  }

  @override
  void dispose() {
    _countryController.dispose();
    _cityController.dispose();
    _address1Controller.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        steps: [
          // Étape 1: Adresse de facturation
          Step(
            title: const Text('Adresse de facturation'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _countryController.text,
                    decoration: const InputDecoration(
                      labelText: 'Pays *',
                      border: OutlineInputBorder(),
                    ),
                    items: AppConfig.countries.map((country) {
                      return DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _countryController.text = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ville *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Ville requise' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _address1Controller,
                    decoration: const InputDecoration(
                      labelText: 'Adresse *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Adresse requise' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _zipCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Code postal *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Code postal requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Téléphone requis' : null,
                  ),
                ],
              ),
            ),
          ),

          // Étape 2: Adresse de livraison
          Step(
            title: const Text('Adresse de livraison'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: const Column(
              children: [
                Text(
                  'Utiliser la même adresse que la facturation',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          // Étape 3: Méthode de livraison
          Step(
            title: const Text('Méthode de livraison'),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                RadioListTile<ShippingMethod>(
                  title: const Text('Ground (Gratuit)'),
                  value: ShippingMethod.ground,
                  groupValue: _shippingMethod,
                  onChanged: (value) {
                    setState(() => _shippingMethod = value!);
                  },
                ),
                RadioListTile<ShippingMethod>(
                  title: const Text('Next Day Air (15€)'),
                  value: ShippingMethod.nextDayAir,
                  groupValue: _shippingMethod,
                  onChanged: (value) {
                    setState(() => _shippingMethod = value!);
                  },
                ),
                RadioListTile<ShippingMethod>(
                  title: const Text('2nd Day Air (10€)'),
                  value: ShippingMethod.secondDayAir,
                  groupValue: _shippingMethod,
                  onChanged: (value) {
                    setState(() => _shippingMethod = value!);
                  },
                ),
              ],
            ),
          ),

          // Étape 4: Méthode de paiement
          Step(
            title: const Text('Méthode de paiement'),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                RadioListTile<PaymentMethod>(
                  title: const Text('Cash On Delivery'),
                  value: PaymentMethod.cashOnDelivery,
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() => _paymentMethod = value!);
                  },
                ),
                RadioListTile<PaymentMethod>(
                  title: const Text('Carte de crédit'),
                  value: PaymentMethod.creditCard,
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() => _paymentMethod = value!);
                  },
                ),
              ],
            ),
          ),

          // Étape 5: Informations de paiement
          Step(
            title: const Text('Informations de paiement'),
            isActive: _currentStep >= 4,
            state: _currentStep > 4 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                Text(
                  _paymentMethod == PaymentMethod.cashOnDelivery
                      ? 'Vous paierez à la livraison'
                      : 'Paiement par carte de crédit',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          // Étape 6: Confirmation
          Step(
            title: const Text('Confirmation'),
            isActive: _currentStep >= 5,
            state: StepState.indexed,
            content: _buildConfirmation(),
          ),
        ],
      ),
    );
  }

  /// Gère le passage à l'étape suivante
  Future<void> _onStepContinue() async {
    if (_currentStep == 0) {
      // Valider le formulaire d'adresse
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      // Dernière étape : confirmer la commande
      await _placeOrder();
    }
  }

  /// Widget de confirmation affichant le résumé de la commande
  Widget _buildConfirmation() {
    final cartProvider = context.watch<CartProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Récapitulatif de votre commande',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Articles
        ...cartProvider.items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${item.product.name} × ${item.quantity}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  item.formattedSubtotal,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),

        const Divider(height: 32),

        // Totaux
        _buildTotalRow('Sous-total:', cartProvider.formattedSubtotal),
        _buildTotalRow(
          'Livraison:',
          '€${cartProvider.getShippingCost(_shippingMethod.toString().split('.').last).toStringAsFixed(2)}',
        ),
        _buildTotalRow(
          'TVA (20%):',
          '€${cartProvider.tax.toStringAsFixed(2)}',
        ),
        const Divider(height: 32),
        _buildTotalRow(
          'Total:',
          cartProvider.getFormattedTotal(_shippingMethod.toString().split('.').last),
          bold: true,
        ),
      ],
    );
  }

  /// Widget helper pour afficher une ligne de total
  Widget _buildTotalRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 18 : 16,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: bold ? const Color(0xFF5CAF90) : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Passe la commande
  Future<void> _placeOrder() async {
    setState(() => _isProcessing = true);

    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();

    try {
      // Créer les adresses
      final billingAddress = Address(
        id: _uuid.v4(),
        country: _countryController.text,
        city: _cityController.text,
        address1: _address1Controller.text,
        zipCode: _zipCodeController.text,
        phoneNumber: _phoneController.text,
      );

      // Créer la commande
      final order = Order(
        id: _uuid.v4(),
        userId: authProvider.currentUser!.id,
        items: cartProvider.items,
        billingAddress: billingAddress,
        shippingAddress: billingAddress, // Même adresse
        paymentMethod: _paymentMethod,
        shippingMethod: _shippingMethod,
        status: OrderStatus.pending,
        subtotal: cartProvider.subtotal,
        shippingCost: cartProvider.getShippingCost(
          _shippingMethod.toString().split('.').last,
        ),
        tax: cartProvider.tax,
        total: cartProvider.getTotal(_shippingMethod.toString().split('.').last),
        createdAt: DateTime.now(),
      );

      // Sauvegarder la commande
      await DatabaseService.instance.createOrder(order);

      // Vider le panier
      await cartProvider.clearCart();

      setState(() => _isProcessing = false);

      if (!mounted) return;

      // Afficher la page de confirmation
      Navigator.pushReplacementNamed(
        context,
        '/order-confirmation',
        arguments: order.id,
      );
    } catch (e) {
      setState(() => _isProcessing = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la commande: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
