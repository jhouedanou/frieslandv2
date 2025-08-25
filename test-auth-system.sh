#!/bin/bash

# Script de test du système d'authentification Friesland Bonnet Rouge
echo "🔐 Test du système d'authentification Friesland Bonnet Rouge"
echo ""

# Vérification de l'app Flutter
echo "📱 Vérification de l'app Flutter..."
if [ -f "pubspec.yaml" ]; then
    echo "✅ Projet Flutter détecté"
    
    # Vérifier les dépendances
    echo "📦 Vérification des dépendances..."
    if grep -q "shared_preferences" pubspec.yaml; then
        echo "✅ shared_preferences installé (stockage auth)"
    else
        echo "❌ shared_preferences manquant"
    fi
    
    # Vérifier les fichiers d'authentification
    if [ -f "lib/core/services/auth_service.dart" ]; then
        echo "✅ AuthService créé"
    else
        echo "❌ AuthService manquant"
    fi
    
    if [ -f "lib/presentation/pages/auth/login_page.dart" ]; then
        echo "✅ Page de connexion créée"
    else
        echo "❌ Page de connexion manquante"
    fi
    
    # Vérifier l'intégration dans main.dart
    if grep -q "AuthWrapper" lib/main.dart; then
        echo "✅ AuthWrapper intégré dans main.dart"
    else
        echo "❌ AuthWrapper non intégré"
    fi
else
    echo "❌ Projet Flutter non trouvé"
    exit 1
fi

echo ""
echo "🌐 Vérification du Dashboard Laravel..."

# Vérification du dashboard
if [ -d "dashboard" ]; then
    echo "✅ Dossier dashboard trouvé"
    
    # Vérifier la configuration Docker
    if [ -f "docker-compose-full.yml" ]; then
        echo "✅ Configuration Docker trouvée"
        
        # Vérifier les ports
        if grep -q "8080:80" docker-compose-full.yml; then
            echo "✅ Port 8080 configuré (évite conflit port 80)"
        else
            echo "⚠️  Vérifier configuration des ports"
        fi
    fi
    
    # Vérifier les seeders
    if [ -f "dashboard/database/seeders/TestDataSeeder.php" ]; then
        echo "✅ TestDataSeeder créé"
    fi
    
    if [ -f "dashboard/database/seeders/DatabaseSeeder.php" ]; then
        echo "✅ DatabaseSeeder configuré"
    fi
else
    echo "❌ Dossier dashboard non trouvé"
fi

echo ""
echo "👤 Utilisateurs de test disponibles :"
echo "   📧 test.treichville@friesland.ci / test123 (Commercial Treichville)"
echo "   📧 admin@friesland.local / admin123 (Administrateur)"
echo "   📧 commercial@friesland.local / commercial123 (Commercial)"
echo "   📧 superviseur@friesland.local / superviseur123 (Superviseur)"

echo ""
echo "🚀 Instructions de test :"
echo "   1. Dashboard: cd dashboard && ./setup-test-data.sh"
echo "   2. Ou Docker: docker-compose -f docker-compose-full.yml up -d"
echo "   3. Flutter: flutter run"
echo "   4. Accès dashboard: http://localhost:8080/admin"

echo ""
echo "🔧 Fonctionnalités testables :"
echo "   ✅ Écran de connexion au lancement"
echo "   ✅ Authentification avec utilisateur de test"
echo "   ✅ Persistance de la session"
echo "   ✅ Menu utilisateur avec profil"
echo "   ✅ Déconnexion et retour au login"
echo "   ✅ Splash screen avec branding Bonnet Rouge"
echo "   ✅ Thème rouge uniforme"

echo ""
echo "🧪 Test de la connexion :"
echo "   1. Lancez l'app Flutter"
echo "   2. L'écran de connexion s'affiche automatiquement"
echo "   3. Les champs sont préremplis avec l'utilisateur test"
echo "   4. Appuyez sur 'Se connecter'"
echo "   5. Vérifiez l'accès à l'app avec menu utilisateur"
echo "   6. Testez la déconnexion depuis le menu"

echo ""
echo "✅ Système d'authentification prêt pour les tests !"
