# Guide de Démarrage - Demo Web Shop Flutter

Ce guide vous accompagne pour lancer l'application Demo Web Shop sur votre machine.

## 📋 Prérequis

### Option 1 : Avec Docker (Recommandé)
- Docker installé et en cours d'exécution
- Docker Compose installé

### Option 2 : Avec Flutter (Développement)
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Pour le web : Chrome ou tout navigateur moderne
- Pour iOS : Xcode (macOS uniquement)
- Pour Android : Android Studio avec SDK

## 🚀 Démarrage Rapide avec Docker

### 1. Créer le dossier de données
```bash
mkdir -p data
```

### 2. Construire l'image Docker
```bash
docker-compose build
```

Cette étape peut prendre plusieurs minutes la première fois (téléchargement de Flutter, build de l'app).

### 3. Lancer le container
```bash
docker-compose up -d
```

### 4. Accéder à l'application
Ouvrez votre navigateur et allez sur :
```
http://localhost:8080
```

### 5. Arrêter l'application
```bash
docker-compose down
```

### 6. Consulter les logs
```bash
docker-compose logs -f demowebshop
```

## 💻 Développement Local (sans Docker)

### 1. Installer les dépendances
```bash
flutter pub get
```

### 2. Vérifier la configuration
```bash
flutter doctor
```

### 3. Lancer l'application

**Pour le Web :**
```bash
flutter run -d chrome
```

**Pour iOS (macOS uniquement) :**
```bash
flutter run -d ios
```

**Pour Android :**
```bash
flutter run -d android
```

### 4. Build de production

**Web :**
```bash
flutter build web --release
```
Les fichiers seront dans `build/web/`

**iOS :**
```bash
flutter build ios --release
```

**Android (APK) :**
```bash
flutter build apk --release
```

**Android (App Bundle) :**
```bash
flutter build appbundle --release
```

## 🔧 Gestion des Volumes Docker

### Consulter les volumes
```bash
docker volume ls | grep demowebshop
```

### Sauvegarder les données
```bash
docker run --rm -v demowebshop-data:/data -v $(pwd):/backup alpine tar czf /backup/backup-data.tar.gz /data
```

### Restaurer les données
```bash
docker run --rm -v demowebshop-data:/data -v $(pwd):/backup alpine sh -c "cd /data && tar xzf /backup/backup-data.tar.gz --strip 1"
```

### Supprimer tous les volumes (⚠️ ATTENTION : perte de données)
```bash
docker-compose down -v
```

## 📱 Tester les Fonctionnalités

### 1. Créer un compte
- Cliquez sur "Register"
- Remplissez le formulaire avec vos informations
- Soumettez le formulaire

### 2. Se connecter
- Cliquez sur "Log in"
- Utilisez l'email et le mot de passe de votre compte

### 3. Explorer le catalogue
- Naviguez dans les catégories (Books, Computers, Electronics)
- Utilisez la barre de recherche

### 4. Ajouter au panier
- Cliquez sur "Add to cart" sur n'importe quel produit
- Le compteur du panier se met à jour en temps réel

### 5. Passer une commande
- Allez dans le panier
- Cochez "I agree with the terms of service"
- Cliquez sur "Checkout"
- Suivez les étapes jusqu'à la confirmation

## 🐛 Dépannage

### Le build Docker échoue
- Vérifiez que Docker a suffisamment de mémoire (au moins 4GB recommandés)
- Supprimez les images et rebuilder :
  ```bash
  docker-compose down
  docker system prune -a
  docker-compose build --no-cache
  ```

### L'application ne se charge pas
- Vérifiez que le container est en cours d'exécution :
  ```bash
  docker ps | grep demowebshop
  ```
- Consultez les logs :
  ```bash
  docker-compose logs -f
  ```

### Erreur de permission sur le dossier data
```bash
sudo chown -R $(whoami):$(whoami) data/
```

### Flutter pub get échoue
```bash
flutter clean
flutter pub get
```

### Problèmes de cache Flutter
```bash
flutter clean
rm -rf ~/.pub-cache
flutter pub get
```

## 📊 Monitoring

### Healthcheck du container
```bash
docker inspect --format='{{.State.Health.Status}}' demowebshop-flutter
```

### Utilisation des ressources
```bash
docker stats demowebshop-flutter
```

## 🔐 Sécurité

- Les mots de passe sont stockés en clair dans cette version de démonstration
- En production, utilisez un système de hashing sécurisé (bcrypt, argon2)
- Les données sont stockées localement dans SQLite
- Pour une utilisation en production, configurez HTTPS

## 📚 Documentation Supplémentaire

- [Flutter Documentation](https://docs.flutter.dev)
- [Docker Documentation](https://docs.docker.com)
- [README principal](README.md)

## 💡 Conseils

1. **Performance** : Le premier build Docker est long, mais les builds suivants utilisent le cache
2. **Développement** : Utilisez `flutter run` pour le hot reload pendant le développement
3. **Production** : Utilisez toujours `--release` pour les builds de production
4. **Données** : Le volume Docker persiste les données entre les redémarrages

## 🆘 Support

Pour toute question ou problème :
1. Consultez les logs : `docker-compose logs -f`
2. Vérifiez la documentation Flutter
3. Créez une issue sur le dépôt GitHub

---

**Bon développement ! 🚀**
