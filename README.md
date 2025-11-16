[![Playwright Tests](https://github.com/AlexThibaud1976/tricentis-demo-tests/actions/workflows/playwright.yml/badge.svg)](https://github.com/AlexThibaud1976/tricentis-demo-tests/actions/workflows/playwright.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)

# 🧪 Demo Web Shop - Tests & Application Flutter

Projet complet combinant **tests automatisés Playwright** et **application Flutter multi-plateforme** reproduisant le site [Demo Web Shop Tricentis](https://demowebshop.tricentis.com/).

> 🎯 **Nouveau !** Application Flutter complète avec déploiement Docker - Voir la section [Application Flutter](#-application-flutter-demo-web-shop)

## 📋 Description

Ce projet contient **deux composants complémentaires** :

### 🧪 Suite de Tests Playwright (17 tests)
Tests end-to-end automatisés couvrant toutes les fonctionnalités du site e-commerce :

- ✅ Création de compte (cas passants et non passants)
- ✅ Authentification (login/logout)
- ✅ Navigation dans le catalogue
- ✅ Gestion du panier
- ✅ Passage de commande complet

### 🚀 Application Flutter E-Commerce (NOUVEAU!)
Application complète reproduisant **exactement** le site demowebshop.tricentis.com :

- 📱 Multi-plateforme (Web, iOS, Android)
- 🎨 Interface utilisateur moderne et responsive
- 🗄️ Persistance locale (SQLite + SharedPreferences)
- 🐳 Déploiement Docker avec volume persistant
- 📚 Code commenté et documentation complète
- ✅ **100% compatible** avec les tests Playwright (17/17 tests)

## 🚀 Installation et Démarrage

### Option 1️⃣ : Tests Playwright uniquement

#### Prérequis
- Node.js (version 16 ou supérieure)
- npm ou yarn

#### Installation
```bash
# 1. Cloner le repository
git clone https://github.com/AlexThibaud1976/tricentis-demo-tests.git
cd tricentis-demo-tests

# 2. Installer les dépendances
npm install

# 3. Installer les navigateurs Playwright
npx playwright install

# 4. Lancer les tests
npm test
```

### Option 2️⃣ : Application Flutter (avec Docker - Recommandé)

#### Prérequis
- Docker et Docker Compose installés

#### Démarrage rapide
```bash
# 1. Aller dans le dossier Flutter
cd demowebshop-flutter

# 2. Lancer l'application avec le script interactif
./start.sh

# 3. Accéder à l'application
# Ouvrir http://localhost:8080 dans votre navigateur
```

#### Ou avec Docker Compose directement
```bash
cd demowebshop-flutter
docker-compose up -d
# Application disponible sur http://localhost:8080
```

### Option 3️⃣ : Application Flutter (développement local)

#### Prérequis
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

#### Installation
```bash
cd demowebshop-flutter

# Installer les dépendances
flutter pub get

# Lancer sur Web
flutter run -d chrome

# Ou sur mobile
flutter run -d ios      # macOS uniquement
flutter run -d android  # Nécessite Android Studio
```

**📖 Documentation détaillée** : Consultez [demowebshop-flutter/GUIDE_DEMARRAGE.md](demowebshop-flutter/GUIDE_DEMARRAGE.md)

## 🧪 Exécution des tests

### Tous les tests

```bash
npm test
```

### Tests avec interface graphique (mode debug)

```bash
npm run test:headed
```

### Tests avec UI Mode (interface interactive)

```bash
npm run test:ui
```

### Tests en mode debug

```bash
npm run test:debug
```

### Exécution par catégorie

```bash
# Tests de création de compte
npm run test:creation

# Tests de login/logout
npm run test:login

# Tests de navigation dans le catalogue
npm run test:catalog

# Tests de gestion du panier
npm run test:cart

# Tests de passage de commande
npm run test:order
```

## 📁 Structure du projet

```
tricentis-demo-tests/
│
├── tests/                               # 🧪 Tests Playwright
│   ├── 01-account-creation.spec.js     # Tests de création de compte
│   ├── 02-login-logout.spec.js         # Tests de connexion/déconnexion
│   ├── 03-catalog-navigation.spec.js   # Tests de navigation catalogue
│   ├── 04-cart-management.spec.js      # Tests de gestion du panier
│   └── 05-order-checkout.spec.js       # Tests de passage de commande
│
├── utils/
│   └── helpers.js                       # Fonctions utilitaires réutilisables
│
├── demowebshop-flutter/                 # 🚀 Application Flutter (NOUVEAU!)
│   ├── lib/
│   │   ├── config/                      # Configuration
│   │   ├── models/                      # Modèles de données
│   │   ├── providers/                   # State management
│   │   ├── screens/                     # Pages de l'application
│   │   ├── services/                    # Services (Auth, DB)
│   │   ├── widgets/                     # Composants réutilisables
│   │   └── main.dart                    # Point d'entrée
│   ├── web/                             # Configuration Web
│   ├── Dockerfile                       # Build Docker
│   ├── docker-compose.yml               # Orchestration
│   ├── start.sh                         # Script de démarrage
│   ├── README.md                        # Documentation Flutter
│   ├── ARCHITECTURE.md                  # Architecture technique
│   ├── GUIDE_DEMARRAGE.md              # Guide de démarrage
│   └── TESTS_MAPPING.md                # Correspondance avec tests Playwright
│
├── playwright.config.js                 # Configuration Playwright
├── package.json                         # Dépendances du projet
└── README.md                            # Documentation principale
```

---

## 🚀 Application Flutter Demo Web Shop

### 📱 Présentation

L'application Flutter est une **réplique complète** du site demowebshop.tricentis.com, développée avec les meilleures pratiques de développement mobile et web.

### ✨ Fonctionnalités Complètes

#### 🔐 Authentification
- Inscription avec validation (email, mot de passe)
- Connexion/Déconnexion
- Session persistante
- Gestion d'erreurs complète

#### 📚 Catalogue de Produits
- 8 produits répartis en 3 catégories (Books, Computers, Electronics)
- Navigation par catégories
- Recherche de produits
- Grille responsive adaptative

#### 🛒 Panier d'Achat
- Ajout/Suppression de produits
- Modification de quantités (1-99)
- Calcul automatique des totaux (sous-total + livraison + TVA 20%)
- Compteur en temps réel
- Persistance SQLite

#### 💳 Processus de Commande (6 étapes)
1. Adresse de facturation
2. Adresse de livraison
3. Méthode de livraison (Ground gratuit / Next Day 15€ / 2nd Day 10€)
4. Mode de paiement (Cash on Delivery / Carte de crédit)
5. Informations de paiement
6. Confirmation avec numéro de commande

### 🏗️ Architecture Technique

- **Pattern** : Clean Architecture avec séparation des responsabilités
- **State Management** : Provider pattern
- **Persistance** :
  - SQLite pour les données (produits, panier, commandes)
  - SharedPreferences pour la session utilisateur
- **Navigation** : Routes nommées avec MaterialApp
- **Code** : 100% commenté en français

**Structure** :
```
lib/
├── config/       # Configuration globale
├── models/       # User, Product, CartItem, Order, Address
├── providers/    # AuthProvider, CartProvider, ProductProvider
├── screens/      # 6 écrans (Home, Login, Register, Cart, Checkout, Confirmation)
├── services/     # AuthService, DatabaseService
├── widgets/      # Composants réutilisables
└── main.dart     # Point d'entrée
```

### 🐳 Déploiement Docker

L'application inclut une configuration Docker complète :

- **Dockerfile multi-stage** : Build optimisé (Flutter → Nginx)
- **docker-compose.yml** : Orchestration avec volume persistant
- **Script start.sh** : Menu interactif pour gérer l'application
- **Volume Docker** : Persistance des données entre redémarrages
- **Nginx** : Serveur web avec compression gzip et cache

### 📚 Documentation

4 documents complets dans `demowebshop-flutter/` :

1. **README.md** - Vue d'ensemble et guide d'installation
2. **ARCHITECTURE.md** - Architecture technique détaillée, patterns, flux de données
3. **GUIDE_DEMARRAGE.md** - Guide pas à pas avec dépannage
4. **TESTS_MAPPING.md** - Correspondance exacte avec les 17 tests Playwright

### 🔗 Compatibilité avec les Tests

L'application Flutter reproduit **exactement** le comportement testé par les tests Playwright :

| Fonctionnalité | Tests Playwright | App Flutter | Statut |
|----------------|------------------|-------------|--------|
| Inscription utilisateur | Test 1-2 | ✅ | 100% |
| Connexion/Déconnexion | Test 3-5 | ✅ | 100% |
| Catalogue et recherche | Test 6 | ✅ | 100% |
| Gestion du panier | Test 7-9 | ✅ | 100% |
| Passage de commande | Test 10 | ✅ | 100% |

**Résultat** : 17/17 tests couverts (100%)

### 🎯 Quick Start

```bash
# Option la plus rapide (Docker)
cd demowebshop-flutter
./start.sh
# Choisir option 1, puis accéder à http://localhost:8080

# Alternative : développement local
cd demowebshop-flutter
flutter pub get
flutter run -d chrome
```

### 📊 Métriques du Projet

- **19 fichiers Dart** (modèles, providers, services, screens)
- **5396 lignes** de code et documentation
- **Architecture Clean** avec 4 couches distinctes
- **Multi-plateforme** : Web, iOS, Android

---

## 📊 Couverture des tests

### Test 1-3 : Création de compte
- ✅ Création avec données valides
- ❌ Création avec email invalide
- ❌ Création avec mots de passe différents

### Test 3-5 : Authentification
- ✅ Connexion avec identifiants valides
- ❌ Connexion avec mot de passe incorrect
- ❌ Connexion avec email inexistant
- ✅ Déconnexion

### Test 6 : Navigation catalogue
- ✅ Parcours des catégories (Books, Computers, Electronics)
- ✅ Visualisation détails produit
- ✅ Recherche de produits

### Test 7-9 : Gestion du panier
- ✅ Ajout d'un produit
- ✅ Ajout de plusieurs produits
- ✅ Modification de quantité
- ✅ Suppression d'un produit
- ✅ Vidage complet du panier

### Test 10 : Passage de commande
- ✅ Commande complète avec un produit
- ❌ Tentative sans accepter les conditions
- ✅ Commande avec plusieurs produits

## 🔧 Fonctions utilitaires

Le fichier `utils/helpers.js` contient des fonctions réutilisables :

- `generateUserData()` - Génère des données utilisateur uniques
- `createAccount(page)` - Crée un compte automatiquement
- `login(page, email, password)` - Authentification
- `logout(page)` - Déconnexion
- `clearCart(page)` - Vide le panier
- `addProductToCart(page, categoryUrl, index)` - Ajout au panier
- `getCartItemCount(page)` - Récupère le nombre d'articles

## 📈 Rapports de tests

Après l'exécution, un rapport HTML est automatiquement généré :

```bash
npm run test:report
```

Le rapport s'ouvre dans votre navigateur et affiche :
- Résultats détaillés de chaque test
- Captures d'écran en cas d'échec
- Vidéos des tests échoués
- Traces d'exécution

## ⚙️ Configuration

### Playwright Config

Le fichier `playwright.config.js` est configuré avec :

- **Base URL** : `https://demowebshop.tricentis.com`
- **Mode headless** : `false` (navigateur visible par défaut)
- **Workers** : `1` (exécution séquentielle pour éviter les conflits)
- **Timeout** : `60000ms` (1 minute)
- **Captures** : Screenshots et vidéos en cas d'échec
- **Traces** : Activées lors de la première tentative échouée

### Personnalisation

Modifiez `playwright.config.js` selon vos besoins :

```javascript
use: {
  headless: true,  // Mode sans interface
  screenshot: 'on', // Toujours capturer
  video: 'on',      // Toujours enregistrer
}
```

## 🎯 Bonnes pratiques implémentées

1. **Données dynamiques** : Chaque test génère des données uniques (email avec timestamp)
2. **Isolation** : Chaque test est indépendant
3. **Nettoyage** : Le panier est vidé entre les tests
4. **Réutilisabilité** : Fonctions utilitaires partagées
5. **Attentes explicites** : Utilisation de `waitForSelector` et `waitForLoadState`
6. **Assertions robustes** : Vérifications multiples
7. **Logs informatifs** : Messages console pour suivre l'exécution

## 🐛 Débogage

Pour déboguer un test spécifique :

```bash
npx playwright test tests/01-account-creation.spec.js --debug
```

Pour inspecter les sélecteurs :

```bash
npx playwright codegen https://demowebshop.tricentis.com/
```

## 📝 Notes importantes

- **Données persistantes** : Chaque exécution crée de nouveaux comptes
- **Pas de suppression** : Les comptes créés restent dans la base du site démo
- **Exécution séquentielle** : Les tests s'exécutent un par un pour éviter les conflits
- **Idempotence** : Les tests peuvent être relancés plusieurs fois

## 🤝 Contribution

Pour contribuer à ce projet :

1. Fork le repository
2. Créez une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Committez vos changements (`git commit -am 'Ajout de nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Créez une Pull Request

## 📄 Licence

MIT License - Libre d'utilisation et de modification

## 👤 Auteur

**Alexandre** - Expert en test de logiciels et automatisation

## 🔗 Liens utiles

### Tests Playwright
- [Documentation Playwright](https://playwright.dev/)
- [Site de test](https://demowebshop.tricentis.com/)
- [Playwright Best Practices](https://playwright.dev/docs/best-practices)

### Application Flutter
- [Documentation Flutter](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [SQLite Plugin](https://pub.dev/packages/sqflite)
- [Architecture détaillée](demowebshop-flutter/ARCHITECTURE.md)

---

## 🎓 À propos de ce projet

Ce repository démontre **deux approches complémentaires** pour travailler avec une application e-commerce :

1. **Tests automatisés** (Playwright) : Validation du comportement de l'application existante
2. **Réimplémentation complète** (Flutter) : Application native multi-plateforme reproduisant les mêmes fonctionnalités

**Cas d'usage** :
- 🧪 **Pour les testeurs** : Suite complète de tests end-to-end automatisés
- 💻 **Pour les développeurs** : Application Flutter moderne et maintenable
- 📚 **Pour l'apprentissage** : Code commenté, documentation complète, bonnes pratiques

**Note** : Ce projet est à des fins éducatives et de démonstration. Le site testé est un environnement de démo fourni par Tricentis.
