#!/bin/bash

echo "🚀 Démarrage Friesland CRM - Configuration Simple"
echo "================================================="
echo ""
echo "1️⃣  PostgreSQL + Dashboard Laravel (Filament + API)"
echo "2️⃣  App Flutter Mobile sur votre device"
echo "3️⃣  Connexion API entre les deux"
echo ""
echo "🐋 Démarrage des services Docker..."

# Arrêter les anciens services
docker-compose -f docker-compose-full.yml down 2>/dev/null || true

# Démarrer l'environnement simple
docker-compose -f docker-compose-simple.yml up -d

echo ""
echo "⏳ Attente du démarrage..."
sleep 30

echo ""
echo "🔧 Configuration de Laravel..."

# Installation des dépendances et migrations
docker exec friesland_dashboard composer install --no-interaction
docker exec friesland_dashboard php artisan key:generate --force
docker exec friesland_dashboard php artisan migrate --force
docker exec friesland_dashboard php artisan db:seed --class=AdminUserSeeder --force

echo ""
echo "🎉 Friesland CRM prêt !"
echo "================================================="
echo ""
echo "📊 Dashboard Filament:"
echo "   URL: http://localhost/admin"
echo "   Admin: admin@friesland.local / admin123"
echo ""
echo "🔌 API Laravel:"
echo "   Base URL: http://localhost/api/v1"
echo "   Test: curl http://localhost/api/health"
echo ""
echo "📱 App Flutter 'Friesland CRM' installée sur votre device A015"
echo "   avec logo Bonnet Rouge"
echo ""
echo "🔗 L'app Flutter se connecte automatiquement à l'API"
echo "================================================="