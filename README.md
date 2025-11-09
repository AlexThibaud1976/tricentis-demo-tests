# 🧪 Suite de Tests Automatisés - Demo Web Shop Tricentis

Suite complète de tests end-to-end automatisés avec Playwright pour le site de démonstration [Demo Web Shop Tricentis](https://demowebshop.tricentis.com/).

## 📋 Description

Ce projet contient **10 tests automatisés** couvrant les fonctionnalités principales du site e-commerce :

- ✅ Création de compte (cas passants et non passants)
- ✅ Authentification (login/logout)
- ✅ Navigation dans le catalogue
- ✅ Gestion du panier
- ✅ Passage de commande complet

## 🚀 Installation

### Prérequis

- Node.js (version 16 ou supérieure)
- npm ou yarn

### Étapes d'installation

1. Cloner le repository :
```bash
git clone https://github.com/votre-username/tricentis-demo-tests.git
cd tricentis-demo-tests
```

2. Installer les dépendances :
```bash
npm install
```

3. Installer les navigateurs Playwright :
```bash
npx playwright install
```

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
├── tests/
│   ├── 01-account-creation.spec.js     # Tests de création de compte
│   ├── 02-login-logout.spec.js         # Tests de connexion/déconnexion
│   ├── 03-catalog-navigation.spec.js   # Tests de navigation catalogue
│   ├── 04-cart-management.spec.js      # Tests de gestion du panier
│   └── 05-order-checkout.spec.js       # Tests de passage de commande
│
├── utils/
│   └── helpers.js                       # Fonctions utilitaires réutilisables
│
├── playwright.config.js                 # Configuration Playwright
├── package.json                         # Dépendances du projet
└── README.md                            # Documentation
```

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

- [Documentation Playwright](https://playwright.dev/)
- [Site de test](https://demowebshop.tricentis.com/)
- [Playwright Best Practices](https://playwright.dev/docs/best-practices)

---

**Note** : Ce projet est à des fins éducatives et de démonstration. Le site testé est un environnement de démo fourni par Tricentis.
