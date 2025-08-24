#!/bin/bash

echo "🚀 Démarrage de l'environnement de développement Friesland"
echo "================================================================"

# Vérifier que Docker est en cours d'exécution
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker n'est pas en cours d'exécution. Veuillez démarrer Docker d'abord."
    exit 1
fi

# Vérifier que Docker Compose est installé
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé."
    exit 1
fi

echo "📋 Vérification des prérequis... ✅"

# Créer les répertoires nécessaires s'ils n'existent pas
mkdir -p dashboard/storage/app/public/visites/photos
mkdir -p dashboard/storage/app/public/visites/signatures
mkdir -p dashboard/storage/framework/cache
mkdir -p dashboard/storage/framework/sessions
mkdir -p dashboard/storage/framework/views
mkdir -p dashboard/storage/logs

echo "📁 Création des répertoires... ✅"

# Copier le fichier .env pour le dashboard s'il n'existe pas
if [ ! -f dashboard/.env ]; then
    cp dashboard/env.example dashboard/.env
    echo "📝 Fichier .env créé pour le dashboard"
fi

echo "🐋 Démarrage des conteneurs Docker..."
docker-compose -f docker-compose-full.yml up -d --build

echo "⏳ Attente du démarrage des services..."
sleep 30

# Vérifier la santé des services
echo "🔍 Vérification de la santé des services..."

# Vérifier PostgreSQL
if docker-compose -f docker-compose-full.yml exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "✅ PostgreSQL: En ligne"
else
    echo "❌ PostgreSQL: Hors ligne"
fi

# Vérifier le dashboard Laravel
if curl -s -f http://localhost/api/health > /dev/null 2>&1; then
    echo "✅ Dashboard API: En ligne"
else
    echo "⚠️ Dashboard API: En attente... (peut prendre quelques minutes de plus)"
fi

echo "🔧 Configuration du dashboard Laravel..."

# Installer les dépendances Laravel
docker-compose -f docker-compose-full.yml exec dashboard composer install

# Générer la clé d'application
docker-compose -f docker-compose-full.yml exec dashboard php artisan key:generate

# Exécuter les migrations
docker-compose -f docker-compose-full.yml exec dashboard php artisan migrate --force

# Créer un utilisateur de test
docker-compose -f docker-compose-full.yml exec dashboard php artisan tinker --execute="
\$user = new App\Models\User();
\$user->name = 'Commercial Test';
\$user->email = 'commercial@friesland.test';
\$user->password = bcrypt('password123');
\$user->role = 'commercial';
\$user->is_active = true;
\$user->save();
echo 'Utilisateur de test créé: commercial@friesland.test / password123';
"

echo ""
echo "🎉 Environnement de développement prêt!"
echo "================================================================"
echo "📱 Services disponibles:"
echo "  - Dashboard API:     http://localhost/api/v1"
echo "  - Interface Admin:   http://localhost (si Filament est configuré)"
echo "  - Base de données:   localhost:5432 (postgres/password)"
echo "  - Adminer:           http://localhost:8081"
echo "  - Flutter Web:       http://localhost:8080 (si activé)"
echo ""
echo "🧪 Test rapide de l'API:"
echo "curl -X POST http://localhost/api/auth/login \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"email\":\"commercial@friesland.test\",\"password\":\"password123\",\"device_name\":\"test\"}'"
echo ""
echo "📚 Logs des services:"
echo "docker-compose -f docker-compose-full.yml logs -f [service_name]"
echo ""
echo "🛑 Arrêter l'environnement:"
echo "docker-compose -f docker-compose-full.yml down"
echo "================================================================"