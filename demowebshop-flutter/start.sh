#!/bin/bash

# Script de démarrage rapide pour Demo Web Shop
# Ce script facilite le lancement de l'application avec Docker

set -e

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════╗"
echo "║     Demo Web Shop - Flutter App       ║"
echo "║         Démarrage rapide               ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker n'est pas installé.${NC}"
    echo "Veuillez installer Docker avant de continuer."
    exit 1
fi

# Vérifier si Docker Compose est installé
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose n'est pas installé.${NC}"
    echo "Veuillez installer Docker Compose avant de continuer."
    exit 1
fi

# Créer le dossier de données s'il n'existe pas
if [ ! -d "data" ]; then
    echo -e "${YELLOW}📁 Création du dossier de données...${NC}"
    mkdir -p data
fi

# Fonction pour afficher le menu
show_menu() {
    echo ""
    echo -e "${BLUE}Que souhaitez-vous faire ?${NC}"
    echo "1) 🚀 Démarrer l'application"
    echo "2) 🔨 Rebuilder et démarrer l'application"
    echo "3) 🛑 Arrêter l'application"
    echo "4) 📊 Voir les logs"
    echo "5) 🔍 Voir le status"
    echo "6) 🧹 Nettoyer (arrêter et supprimer les containers)"
    echo "7) 💾 Sauvegarder les données"
    echo "8) 📝 Ouvrir le navigateur"
    echo "9) ❌ Quitter"
    echo ""
}

# Fonction pour démarrer l'application
start_app() {
    echo -e "${YELLOW}🚀 Démarrage de l'application...${NC}"

    # Vérifier si l'image existe
    if ! docker images | grep -q "demowebshop-flutter"; then
        echo -e "${YELLOW}📦 Première fois : construction de l'image (cela peut prendre plusieurs minutes)...${NC}"
        docker-compose build
    fi

    docker-compose up -d

    echo -e "${GREEN}✅ Application démarrée avec succès !${NC}"
    echo -e "${GREEN}🌐 Accédez à l'application sur : http://localhost:8080${NC}"
}

# Fonction pour rebuilder
rebuild_app() {
    echo -e "${YELLOW}🔨 Reconstruction de l'image...${NC}"
    docker-compose down
    docker-compose build --no-cache
    docker-compose up -d
    echo -e "${GREEN}✅ Application reconstruite et démarrée !${NC}"
}

# Fonction pour arrêter
stop_app() {
    echo -e "${YELLOW}🛑 Arrêt de l'application...${NC}"
    docker-compose down
    echo -e "${GREEN}✅ Application arrêtée.${NC}"
}

# Fonction pour voir les logs
show_logs() {
    echo -e "${BLUE}📊 Logs de l'application (Ctrl+C pour quitter)...${NC}"
    docker-compose logs -f
}

# Fonction pour voir le status
show_status() {
    echo -e "${BLUE}🔍 Status des containers :${NC}"
    docker-compose ps
    echo ""
    echo -e "${BLUE}📊 Utilisation des ressources :${NC}"
    docker stats --no-stream demowebshop-flutter 2>/dev/null || echo "Container non démarré"
}

# Fonction pour nettoyer
clean_app() {
    echo -e "${YELLOW}🧹 Nettoyage...${NC}"
    read -p "⚠️  Voulez-vous aussi supprimer les volumes (données) ? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose down -v
        echo -e "${GREEN}✅ Containers et volumes supprimés.${NC}"
    else
        docker-compose down
        echo -e "${GREEN}✅ Containers supprimés (volumes conservés).${NC}"
    fi
}

# Fonction pour sauvegarder
backup_data() {
    echo -e "${YELLOW}💾 Sauvegarde des données...${NC}"
    BACKUP_FILE="backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar czf "$BACKUP_FILE" data/
    echo -e "${GREEN}✅ Données sauvegardées dans : $BACKUP_FILE${NC}"
}

# Fonction pour ouvrir le navigateur
open_browser() {
    URL="http://localhost:8080"
    echo -e "${BLUE}🌐 Ouverture du navigateur...${NC}"

    if command -v xdg-open &> /dev/null; then
        xdg-open "$URL"
    elif command -v open &> /dev/null; then
        open "$URL"
    elif command -v start &> /dev/null; then
        start "$URL"
    else
        echo -e "${YELLOW}⚠️  Impossible d'ouvrir automatiquement le navigateur.${NC}"
        echo -e "Veuillez ouvrir manuellement : $URL"
    fi
}

# Boucle principale
while true; do
    show_menu
    read -p "Votre choix (1-9) : " choice

    case $choice in
        1)
            start_app
            ;;
        2)
            rebuild_app
            ;;
        3)
            stop_app
            ;;
        4)
            show_logs
            ;;
        5)
            show_status
            ;;
        6)
            clean_app
            ;;
        7)
            backup_data
            ;;
        8)
            open_browser
            ;;
        9)
            echo -e "${GREEN}👋 Au revoir !${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Choix invalide. Veuillez choisir entre 1 et 9.${NC}"
            ;;
    esac

    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
done
