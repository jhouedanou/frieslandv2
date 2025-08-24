#!/bin/bash

echo "🗄️ Initialisation de la base de données Friesland"
echo "================================================="

# Vérifier que Docker est en cours
if ! docker-compose -f docker-compose-full.yml ps postgres | grep -q "Up"; then
    echo "❌ Le conteneur PostgreSQL n'est pas en cours. Démarrez-le d'abord :"
    echo "docker-compose -f docker-compose-full.yml up -d postgres"
    exit 1
fi

echo "🔧 Configuration du dashboard Laravel..."

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente de PostgreSQL..."
until docker-compose -f docker-compose-full.yml exec -T postgres pg_isready -U postgres > /dev/null 2>&1; do
    echo "  PostgreSQL n'est pas encore prêt - attente..."
    sleep 2
done

echo "✅ PostgreSQL est prêt!"

# Copier le fichier .env s'il n'existe pas
if [ ! -f dashboard/.env ]; then
    cp dashboard/env.example dashboard/.env
    echo "📝 Fichier .env créé"
fi

# Démarrer le conteneur dashboard s'il n'est pas en cours
if ! docker-compose -f docker-compose-full.yml ps dashboard | grep -q "Up"; then
    echo "🚀 Démarrage du dashboard..."
    docker-compose -f docker-compose-full.yml up -d dashboard
    sleep 10
fi

# Installation des dépendances
echo "📦 Installation des dépendances Composer..."
docker-compose -f docker-compose-full.yml exec dashboard composer install --no-interaction

# Génération de la clé d'application
echo "🔑 Génération de la clé d'application..."
docker-compose -f docker-compose-full.yml exec dashboard php artisan key:generate --force

# Configuration du cache
echo "⚡ Configuration du cache..."
docker-compose -f docker-compose-full.yml exec dashboard php artisan config:cache
docker-compose -f docker-compose-full.yml exec dashboard php artisan route:cache

# Migrations de la base de données
echo "🔄 Exécution des migrations..."
docker-compose -f docker-compose-full.yml exec dashboard php artisan migrate --force

# Seeders pour les utilisateurs de test
echo "👥 Création des utilisateurs de test..."
docker-compose -f docker-compose-full.yml exec dashboard php artisan db:seed --class=AdminUserSeeder --force

# Test de connexion à la base
echo "🧪 Test de connexion à la base de données..."
docker-compose -f docker-compose-full.yml exec dashboard php artisan tinker --execute="
try {
    \$users = App\Models\User::count();
    echo \"✅ Connexion BDD réussie - \$users utilisateurs trouvés\n\";
} catch (Exception \$e) {
    echo \"❌ Erreur BDD: \" . \$e->getMessage() . \"\n\";
}
"

# Créer quelques PDVs de test
echo "🏪 Création de PDVs de test..."
docker-compose -f docker-compose-full.yml exec dashboard php artisan tinker --execute="
try {
    App\Models\PDV::create([
        'nom' => 'Super Marché Central',
        'adresse' => '123 Avenue de la République',
        'ville' => 'Abidjan',
        'code_postal' => '01234',
        'pays' => 'Côte d\\'Ivoire',
        'latitude' => 5.3364,
        'longitude' => -4.0267,
        'type_pdv' => 'supermarche',
        'secteur' => 'Cocody',
        'commercial_id' => 2,
        'statut' => 'actif'
    ]);
    
    App\Models\PDV::create([
        'nom' => 'Boutique du Quartier',
        'adresse' => '456 Rue des Palmiers',
        'ville' => 'Abidjan',
        'code_postal' => '01235',
        'pays' => 'Côte d\\'Ivoire',
        'latitude' => 5.3564,
        'longitude' => -4.0467,
        'type_pdv' => 'boutique',
        'secteur' => 'Plateau',
        'commercial_id' => 2,
        'statut' => 'actif'
    ]);
    
    echo \"✅ PDVs de test créés\n\";
} catch (Exception \$e) {
    echo \"⚠️ Erreur création PDV: \" . \$e->getMessage() . \"\n\";
}
"

# Vérifier l'état des services
echo ""
echo "🔍 Vérification des services..."

# Test API Health
if curl -s -f http://localhost/api/health > /dev/null 2>&1; then
    echo "✅ API disponible : http://localhost/api/health"
else
    echo "❌ API non disponible"
fi

# Test Dashboard Admin
if curl -s -f http://localhost/admin > /dev/null 2>&1; then
    echo "✅ Dashboard admin disponible : http://localhost/admin"
else
    echo "⚠️ Dashboard admin peut nécessiter quelques minutes supplémentaires"
fi

echo ""
echo "🎉 Initialisation terminée!"
echo "================================================="
echo "🔐 Accès au Dashboard Filament:"
echo "   URL: http://localhost/admin"
echo "   Admin: admin@friesland.local / admin123"
echo "   Commercial: commercial@friesland.local / commercial123"
echo "   Superviseur: superviseur@friesland.local / superviseur123"
echo ""
echo "🧪 API de test:"
echo "   Health: http://localhost/api/health"
echo "   Login: curl -X POST http://localhost/api/auth/login \\"
echo "          -H 'Content-Type: application/json' \\"
echo "          -d '{\"email\":\"admin@friesland.local\",\"password\":\"admin123\",\"device_name\":\"test\"}'"
echo ""
echo "🗄️ Base de données:"
echo "   Adminer: http://localhost:8081"
echo "   Serveur: postgres"
echo "   Base: friesland_dashboard"
echo "   Utilisateur: postgres"
echo "   Mot de passe: password"
echo "================================================="