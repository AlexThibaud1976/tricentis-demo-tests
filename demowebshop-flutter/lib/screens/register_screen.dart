import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Écran d'inscription
///
/// Permet à un nouvel utilisateur de créer un compte
/// avec validation complète des champs
/// Attributs testables ajoutés pour Playwright
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _gender = 'male';
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      gender: _gender,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      // Afficher un message de succès
      showDialog(
        context: context,
        builder: (context) => Semantics(
          label: 'registration-success-dialog',
          child: AlertDialog(
            title: const Text('Registration Completed'),
            content: Semantics(
              label: 'registration-success-message',
              child: const Text('Your registration completed'),
            ),
            actions: [
              Semantics(
                label: 'register-continue-button',
                button: true,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Fermer le dialog
                    Navigator.pushReplacementNamed(context, '/'); // Retour à l'accueil
                  },
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Afficher l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Semantics(
            label: 'registration-error-message',
            child: Text(authProvider.errorMessage ?? 'Registration failed'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Titre
                      Semantics(
                        label: 'page-title',
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Gender
                      const Text(
                        'Gender:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Semantics(
                            label: 'gender-male',
                            child: Radio<String>(
                              value: 'male',
                              groupValue: _gender,
                              onChanged: (value) =>
                                  setState(() => _gender = value!),
                            ),
                          ),
                          const Text('Male'),
                          const SizedBox(width: 24),
                          Semantics(
                            label: 'gender-female',
                            child: Radio<String>(
                              value: 'female',
                              groupValue: _gender,
                              onChanged: (value) =>
                                  setState(() => _gender = value!),
                            ),
                          ),
                          const Text('Female'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // First Name
                      Semantics(
                        label: 'FirstName',
                        textField: true,
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First name *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'First name is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Last Name
                      Semantics(
                        label: 'LastName',
                        textField: true,
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last name *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Last name is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      Semantics(
                        label: 'Email',
                        textField: true,
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Wrong email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      Semantics(
                        label: 'Password',
                        textField: true,
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password *',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      Semantics(
                        label: 'ConfirmPassword',
                        textField: true,
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Confirm password *',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'The password and confirmation password do not match.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bouton Register
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Semantics(
                          label: 'register-button',
                          button: true,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                    'Register',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Lien vers login
                      Center(
                        child: Semantics(
                          label: 'link-to-login',
                          link: true,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text('Already have an account? Log in'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
