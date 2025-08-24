#!/bin/bash

echo "🚀 Installation du Dashboard Friesland Filament"
echo "=============================================="

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

echo "✅ Docker et Docker Compose sont installés"

# Copier le fichier d'environnement
if [ ! -f .env ]; then
    echo "📝 Copie du fichier d'environnement..."
    cp env.example .env
    echo "✅ Fichier .env créé"
else
    echo "ℹ️  Fichier .env existe déjà"
fi

# Démarrer les services
echo "🐳 Démarrage des services Docker..."
docker-compose up -d

# Attendre que les services soient prêts
echo "⏳ Attente du démarrage des services..."
sleep 30

# Vérifier que PostgreSQL est prêt
echo "🔍 Vérification de la base de données..."
until docker-compose exec -T postgres-local pg_isready -U friesland_user -d friesland_db; do
    echo "⏳ Attente de PostgreSQL..."
    sleep 5
done

echo "✅ Base de données prête"

# Installer les dépendances PHP
echo "📦 Installation des dépendances PHP..."
docker-compose exec dashboard composer install --no-dev --optimize-autoloader

# Générer la clé d'application
echo "🔑 Génération de la clé d'application..."
docker-compose exec dashboard php artisan key:generate

# Lancer les migrations
echo "🗄️  Lancement des migrations..."
docker-compose exec dashboard php artisan migrate --force

# Créer un utilisateur admin
echo "👤 Création d'un utilisateur administrateur..."
echo "Veuillez entrer les informations pour l'utilisateur admin :"
read -p "Nom: " admin_name
read -p "Email: " admin_email
read -s -p "Mot de passe: " admin_password
echo

# Créer l'utilisateur via tinker
docker-compose exec dashboard php artisan tinker --execute="
use App\Models\User;
use Illuminate\Support\Facades\Hash;

User::create([
    'name' => '$admin_name',
    'email' => '$admin_email',
    'password' => Hash::make('$admin_password'),
    'role' => 'admin',
    'is_active' => true,
]);

echo 'Utilisateur admin créé avec succès!';
"

echo ""
echo "🎉 Installation terminée avec succès!"
echo ""
echo "📱 Dashboard accessible sur : http://localhost:8081/admin"
echo "👤 Identifiants de connexion :"
echo "   Email: $admin_email"
echo "   Mot de passe: [celui que vous avez saisi]"
echo ""
echo "🔧 Commandes utiles :"
echo "   - Arrêter : docker-compose down"
echo "   - Logs : docker-compose logs -f dashboard"
echo "   - Shell : docker-compose exec dashboard bash"
echo ""
echo "🚀 Bonne utilisation du Dashboard Friesland!" 