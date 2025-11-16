# Dockerfile pour l'application Demo Web Shop Flutter
# Construit l'application pour le web et la sert via nginx

# Stage 1: Build de l'application Flutter pour le web
FROM debian:latest AS build-env

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    libgconf-2-4 \
    gdb \
    libstdc++6 \
    libglu1-mesa \
    fonts-droid-fallback \
    lib32stdc++6 \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Installation de Flutter
ARG FLUTTER_VERSION=3.19.0
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b ${FLUTTER_VERSION}
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Préconfiguration de Flutter
RUN flutter doctor -v
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Répertoire de travail
WORKDIR /app

# Copie des fichiers de configuration Flutter
COPY pubspec.* ./

# Installation des dépendances
RUN flutter pub get

# Copie de tout le code source
COPY . .

# Build de l'application web en mode release
RUN flutter build web --release

# Stage 2: Servir l'application avec nginx
FROM nginx:alpine

# Copie de la configuration nginx personnalisée
COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name localhost;

    root /usr/share/nginx/html;
    index index.html;

    # Gestion du routing Flutter (SPA)
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Headers de sécurité
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Compression gzip
    gzip on;
    gzip_vary on;
    gzip_min_length 10240;
    gzip_proxied expired no-cache no-store private auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/javascript application/xml+rss;
    gzip_disable "MSIE [1-6]\.";

    # Cache pour les assets statiques
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Copie des fichiers buildés depuis le stage précédent
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Volume pour la persistance des données
VOLUME ["/var/lib/nginx/data"]

# Exposition du port
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Démarrage de nginx
CMD ["nginx", "-g", "daemon off;"]
