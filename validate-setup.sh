#!/bin/bash

# Script de validation de l'installation Friesland Bonnet Rouge
echo "🔍 Validation de l'installation Friesland Bonnet Rouge"
echo "📍 Configuration test Treichville - rue Roger Abinader"
echo ""

# Fonction pour afficher les résultats
check_result() {
    if [ $1 -eq 0 ]; then
        echo "✅ $2"
    else
        echo "❌ $2"
        return 1
    fi
}

# Vérifier Flutter
echo "📱 Vérification Flutter..."
flutter --version > /dev/null 2>&1
check_result $? "Flutter installé"

flutter pub get > /dev/null 2>&1
check_result $? "Dépendances Flutter installées"

# Vérifier les dépendances spécifiques
echo ""
echo "📦 Vérification dépendances critiques..."

grep -q "flutter_map: \^7.0.2" pubspec.yaml
check_result $? "flutter_map (OpenStreetMap)"

grep -q "geolocator: \^13.0.1" pubspec.yaml  
check_result $? "geolocator (GPS)"

grep -q "latlong2: \^0.9.1" pubspec.yaml
check_result $? "latlong2 (Coordonnées)"

# Vérifier la structure des fichiers
echo ""
echo "🗂️  Vérification structure projet..."

[ -f "lib/core/services/map_service.dart" ]
check_result $? "MapService (OpenStreetMap)"

[ -f "lib/presentation/pages/map_page.dart" ]
check_result $? "MapPage (Interface carte)"

[ -f "lib/presentation/pages/visit_creation/geofence_validation_page.dart" ]
check_result $? "GeofenceValidationPage (Validation 300m)"

# Vérifier Dashboard Laravel
echo ""
echo "🌐 Vérification Dashboard Laravel..."

[ -f "dashboard/app/Models/PDV.php" ]
check_result $? "Modèle PDV"

[ -f "dashboard/database/seeders/TestDataSeeder.php" ]
check_result $? "TestDataSeeder (Utilisateur test)"

[ -f "dashboard/database/seeders/RoutingSeeder.php" ]
check_result $? "RoutingSeeder (PDV Treichville)"

[ -f "dashboard/setup-test-data.sh" ]
check_result $? "Script d'installation"

# Vérifier la conformité CLAUDE.md
echo ""
echo "📋 Vérification conformité CLAUDE.md..."

grep -q "300.0" lib/core/services/map_service.dart
check_result $? "Géofencing 300m par défaut"

grep -q "#E53E3E" lib/core/services/map_service.dart
check_result $? "Couleur Bonnet Rouge (#E53E3E)"

grep -q "Treichville" dashboard/database/seeders/TestDataSeeder.php
check_result $? "PDV Treichville configurés"

grep -q "roger_abinader" dashboard/database/seeders/TestDataSeeder.php || grep -q "Roger Abinader" dashboard/database/seeders/TestDataSeeder.php
check_result $? "Rue Roger Abinader"

# Vérifications techniques spécifiques
echo ""
echo "⚙️  Vérifications techniques..."

grep -q "OpenStreetMap" lib/core/services/map_service.dart
check_result $? "Intégration OpenStreetMap"

grep -q "isWithinGeofence" lib/core/services/map_service.dart
check_result $? "Validation géofencing"

grep -q "calculateOptimizedRoute" lib/core/services/map_service.dart
check_result $? "Optimisation de tournée"

grep -q "test.treichville@friesland.ci" dashboard/database/seeders/TestDataSeeder.php
check_result $? "Utilisateur test Treichville"

# Résumé
echo ""
echo "📊 Résumé de la configuration:"
echo "   👤 Utilisateur: test.treichville@friesland.ci / test123"
echo "   📍 Zone: Treichville, rue Roger Abinader"
echo "   🏪 PDV: 8 points de vente (5 rue principale + 3 alternatives)"
echo "   🗺️  Carte: OpenStreetMap avec géofencing 300m"
echo "   📱 App: Flutter avec service de géolocalisation"
echo "   🌐 Dashboard: Laravel/Filament avec données de test"
echo ""
echo "🚀 Instructions de lancement:"
echo "   1. Dashboard: cd dashboard && ./setup-test-data.sh && php artisan serve"
echo "   2. Flutter: flutter run"
echo "   3. Accès: http://localhost:8000/admin"
echo ""
echo "🎯 Test recommandé:"
echo "   - Ouvrir l'app Flutter"
echo "   - Appuyer sur le bouton 'Carte' (icône map)"
echo "   - Vérifier l'affichage des PDV Treichville"
echo "   - Tester le géofencing avec coordonnées: 5.2500, -4.0235"
echo ""
echo "✅ Validation terminée !"
