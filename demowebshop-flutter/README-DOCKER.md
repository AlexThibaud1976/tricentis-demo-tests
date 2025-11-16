# 🐳 Guide Docker - Demo Web Shop Flutter

Ce guide vous explique comment lancer l'application Demo Web Shop Flutter avec Docker.

## 📋 Prérequis

- **Docker** version 20.10 ou supérieure
- **Docker Compose** version 2.0 ou supérieure (ou `docker-compose` v1.29+)
- Au moins **2 GB de RAM** disponible pour le build
- Au moins **1 GB d'espace disque** disponible

### Vérifier les installations

```bash
docker --version
docker compose version  # ou docker-compose --version
```

## 🚀 Démarrage rapide

### Option 1: Script interactif (recommandé)

Le script `start.sh` offre un menu interactif pour gérer l'application:

```bash
cd demowebshop-flutter
chmod +x start.sh
./start.sh
```

Menu disponible:
1. 🚀 Démarrer l'application
2. 🔨 Rebuilder et démarrer
3. 🛑 Arrêter l'application
4. 📊 Voir les logs
5. 🔍 Voir le status
6. 🧹 Nettoyer
7. 💾 Sauvegarder les données
8. 📝 Ouvrir le navigateur
9. ❌ Quitter

### Option 2: Docker Compose

```bash
# Build et démarrage
docker compose up -d --build

# Voir les logs
docker compose logs -f

# Arrêter
docker compose down
```

### Option 3: Docker manuel

```bash
# Build de l'image
docker build -t demowebshop-flutter .

# Lancement du container
docker run -d \
  --name demowebshop \
  -p 8080:80 \
  --restart unless-stopped \
  demowebshop-flutter

# Voir les logs
docker logs -f demowebshop

# Arrêter
docker stop demowebshop
docker rm demowebshop
```

## 🌐 Accès à l'application

Une fois l'application démarrée, ouvrez votre navigateur à:

**http://localhost:8080**

## 📊 Commandes utiles

### Gestion de l'application

```bash
# Démarrer
docker compose up -d

# Arrêter
docker compose down

# Redémarrer
docker compose restart

# Rebuild complet
docker compose up -d --build --force-recreate

# Voir le status
docker compose ps
```

### Logs et debugging

```bash
# Logs en temps réel
docker compose logs -f

# Logs d'un service spécifique
docker compose logs -f demowebshop

# Dernières 100 lignes
docker compose logs --tail=100

# Logs depuis les 10 dernières minutes
docker compose logs --since=10m
```

### Inspection

```bash
# Entrer dans le container
docker compose exec demowebshop sh

# Voir les ressources utilisées
docker stats demowebshop-flutter

# Inspecter le container
docker inspect demowebshop-flutter
```

## 🔧 Configuration

### Variables d'environnement

Modifiez `docker-compose.yml` pour ajuster:

```yaml
environment:
  - TZ=Europe/Paris  # Timezone
```

### Ports

Par défaut, l'application écoute sur le port **8080**. Pour changer:

```yaml
ports:
  - "3000:80"  # Utiliser le port 3000 au lieu de 8080
```

### Volumes

Les données sont persistées dans le volume `demowebshop-data`:

```bash
# Lister les volumes
docker volume ls

# Inspecter le volume
docker volume inspect demowebshop-flutter_demowebshop-data

# Sauvegarder les données
tar czf backup.tar.gz ./data/
```

## 🐛 Résolution de problèmes

### Le build échoue

```bash
# Nettoyer le cache Docker
docker builder prune -a

# Rebuild sans cache
docker compose build --no-cache
```

### Le container ne démarre pas

```bash
# Voir les logs d'erreur
docker compose logs

# Vérifier le status
docker compose ps -a

# Vérifier les ports utilisés
netstat -an | grep 8080  # Linux/Mac
# ou
Get-NetTCPConnection -LocalPort 8080  # Windows PowerShell
```

### Port 8080 déjà utilisé

```bash
# Option 1: Changer le port dans docker-compose.yml
ports:
  - "8081:80"

# Option 2: Trouver et arrêter le processus utilisant le port
lsof -i :8080  # Linux/Mac
```

### L'application ne répond pas

```bash
# Vérifier le healthcheck
docker inspect demowebshop-flutter | grep -A 10 Health

# Redémarrer le container
docker compose restart

# Rebuild complet
docker compose down
docker compose up -d --build --force-recreate
```

## 🧹 Nettoyage

### Arrêter et supprimer les containers

```bash
# Garder les volumes (données)
docker compose down

# Supprimer aussi les volumes
docker compose down -v
```

### Nettoyer tout Docker

```bash
# Supprimer les containers arrêtés
docker container prune

# Supprimer les images non utilisées
docker image prune -a

# Supprimer les volumes non utilisés
docker volume prune

# Tout nettoyer (attention!)
docker system prune -a --volumes
```

## 📦 Build optimisé

Le Dockerfile utilise un build multi-stage pour optimiser la taille finale:

- **Stage 1**: Build Flutter (Debian Bullseye) - ~2.5 GB
- **Stage 2**: Runtime Nginx (Alpine) - ~50 MB final

### Temps de build

Premier build: **10-15 minutes** (téléchargement de Flutter)
Builds suivants: **2-5 minutes** (cache Docker)

### Taille de l'image

- Image de build: ~2.5 GB
- Image finale: ~50 MB

## 🔒 Sécurité

L'application inclut:

- ✅ Headers de sécurité (X-Frame-Options, X-XSS-Protection, etc.)
- ✅ Compression Gzip
- ✅ Cache optimisé pour les assets
- ✅ Healthcheck automatique
- ✅ Restart policy (unless-stopped)

## 📚 Structure des fichiers

```
demowebshop-flutter/
├── Dockerfile              # Configuration Docker multi-stage
├── docker-compose.yml      # Orchestration Docker Compose
├── .dockerignore          # Fichiers exclus du build
├── start.sh               # Script de gestion interactif
├── data/                  # Données persistantes (volume)
└── ...                    # Code source Flutter
```

## 🆘 Support

En cas de problème:

1. Consultez les logs: `docker compose logs -f`
2. Vérifiez le status: `docker compose ps`
3. Essayez un rebuild: `docker compose up -d --build --force-recreate`

## 📝 Notes importantes

- **Persistance**: Les données SQLite sont stockées dans IndexedDB du navigateur (localStorage)
- **Performance**: Le premier chargement peut prendre quelques secondes (téléchargement des assets WASM)
- **Compatibilité**: Testé sur Chrome, Firefox, Safari, Edge
- **Réseau**: L'application fonctionne en mode SPA (Single Page Application)

## 🎯 Prochaines étapes

Une fois l'application lancée:

1. Ouvrez http://localhost:8080
2. Créez un compte utilisateur
3. Explorez le catalogue de produits
4. Testez le processus de commande

Bon développement! 🚀
