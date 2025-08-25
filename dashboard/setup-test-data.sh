#!/bin/bash

# Script de configuration des données de test Friesland Bonnet Rouge
# Treichville - rue Roger Abinader

echo "🚀 Configuration des données de test Friesland Bonnet Rouge"
echo "📍 Focus: Treichville - rue Roger Abinader"
echo ""

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "composer.json" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis le dossier dashboard"
    exit 1
fi

echo "📦 Installation des dépendances Composer..."
composer install --no-dev --optimize-autoloader

echo "⚙️  Configuration de l'environnement..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "✅ Fichier .env créé"
fi

# Générer la clé d'application si nécessaire
if ! grep -q "APP_KEY=base64:" .env; then
    echo "🔑 Génération de la clé d'application..."
    php artisan key:generate
fi

echo "🗄️  Configuration de la base de données..."
# Créer les tables
php artisan migrate:fresh --force

echo "🌱 Exécution des seeders..."
# Exécuter nos seeders personnalisés
php artisan db:seed --class=RolePermissionSeeder
php artisan db:seed --class=AdminUserSeeder  
php artisan db:seed --class=TestDataSeeder
php artisan db:seed --class=RoutingSeeder

echo ""
echo "✅ Configuration terminée avec succès !"
echo ""
echo "📋 Comptes utilisateurs créés :"
echo "   👤 Admin: admin@friesland.local / admin123"
echo "   👤 Commercial: commercial@friesland.local / commercial123"
echo "   👤 Superviseur: superviseur@friesland.local / superviseur123"
echo "   👤 Test Treichville: test.treichville@friesland.ci / test123"
echo ""
echo "📍 PDV créés à Treichville :"
echo "   🛣️  5 PDV rue Roger Abinader (tournée principale)"
echo "   🏪 3 PDV zone portuaire (tournée alternative)"
echo "   📊 Total: 8 PDV pour tests"
echo ""
echo "🌐 Accès au dashboard:"
echo "   Local: http://localhost/admin"
echo "   Docker: http://localhost:8080/admin"
echo ""
echo "📱 Pour tester l'app Flutter :"
echo "   1. Ouvrez le projet Flutter"
echo "   2. Lancez: flutter pub get"
echo "   3. Démarrez l'app sur un émulateur/device"
echo "   4. Utilisez le bouton 'Carte' pour voir les PDV"
echo ""
echo "🗺️  Coordonnées de test Treichville :"
echo "   Centre: 5.2500, -4.0235 (rue Roger Abinader)"
echo "   Rayon géofencing: 300m par PDV"
echo ""
