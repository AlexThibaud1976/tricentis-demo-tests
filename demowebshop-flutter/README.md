# Demo Web Shop - Application Flutter

Une application e-commerce complète développée avec Flutter et Dart, reproduisant fidèlement le site [demowebshop.tricentis.com](https://demowebshop.tricentis.com).

## 🎯 Caractéristiques

- **Multi-plateforme** : Compatible Web, iOS et Android
- **Architecture Clean** : Code organisé, maintenable et testable
- **State Management** : Utilisation de Provider pour une gestion d'état robuste
- **Persistance des données** : SQLite pour les produits, SharedPreferences pour les préférences utilisateur
- **Navigation moderne** : GoRouter pour une navigation déclarative
- **Code de qualité** : Respecte les meilleures pratiques Flutter et est entièrement commenté

## 📋 Fonctionnalités

### Authentification
- ✅ Inscription utilisateur avec validation complète
- ✅ Connexion / Déconnexion
- ✅ Gestion de session
- ✅ Validation des formulaires

### Catalogue de produits
- ✅ Navigation par catégories (Books, Computers, Electronics, etc.)
- ✅ Recherche de produits
- ✅ Affichage des détails de produit
- ✅ Grille de produits responsive

### Panier d'achat
- ✅ Ajout / Suppression de produits
- ✅ Modification des quantités
- ✅ Calcul automatique des totaux
- ✅ Compteur temps réel
- ✅ Persistance du panier

### Processus de commande
- ✅ Formulaire d'adresse de facturation
- ✅ Sélection de l'adresse de livraison
- ✅ Choix de la méthode de livraison
- ✅ Choix du mode de paiement
- ✅ Récapitulatif de commande
- ✅ Confirmation et numéro de commande

## 🏗️ Architecture

```
lib/
├── config/          # Configuration de l'application
├── models/          # Modèles de données
├── providers/       # State management (Provider)
├── screens/         # Pages de l'application
├── services/        # Services (API, Database, Auth)
├── utils/           # Utilitaires et helpers
└── widgets/         # Composants réutilisables
```

## 🚀 Installation

### Prérequis
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

### Installation des dépendances
```bash
flutter pub get
```

### Lancement de l'application

**Web :**
```bash
flutter run -d chrome
```

**iOS :**
```bash
flutter run -d ios
```

**Android :**
```bash
flutter run -d android
```

## 🐳 Docker

### Construction de l'image
```bash
docker build -t demowebshop-flutter .
```

### Lancement du container
```bash
docker-compose up -d
```

L'application sera accessible sur http://localhost:8080

### Volume de persistance
Les données sont persistées dans le volume `demowebshop-data` défini dans docker-compose.yml

## 🧪 Tests

```bash
# Lancer tous les tests
flutter test

# Tests avec coverage
flutter test --coverage
```

## 📦 Build de production

**Web :**
```bash
flutter build web --release
```

**iOS :**
```bash
flutter build ios --release
```

**Android :**
```bash
flutter build apk --release
# ou pour un App Bundle
flutter build appbundle --release
```

## 🔧 Configuration

Les configurations sont dans `lib/config/app_config.dart`

## 📝 Licence

Ce projet est développé à des fins de démonstration et d'apprentissage.

## 👨‍💻 Développement

Ce code suit les meilleures pratiques de développement Flutter :
- Architecture Clean avec séparation des responsabilités
- Code entièrement commenté en français
- Gestion d'état avec Provider
- Repository pattern pour l'accès aux données
- Validation complète des formulaires
- Gestion des erreurs
- Responsive design

## 📞 Support

Pour toute question ou problème, veuillez créer une issue sur le dépôt GitHub.
