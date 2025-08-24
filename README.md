# Friesland Dashboard - Application de Gestion des Visites Commerciales

Application Flutter complète pour la gestion des visites commerciales Friesland Bonnet Rouge avec dashboard temps réel et contrôles géofencing avancés.

## 🚀 Fonctionnalités Principales

### 📊 Dashboard Temps Réel
- **KPI en temps réel** : Visites, PDV actifs, prix respectés, alertes
- **Graphiques interactifs** : Présence produits par catégorie (EVAP, IMP, SCM, UHT, YOGHURT)
- **Performance commerciaux** : Suivi individuel et comparatif
- **Alertes automatiques** : Ruptures stock, prix non respectés

### 📍 Géofencing Avancé
- **Validation proximité PDV** : Rayon 300m obligatoire
- **Précision GPS minimum** : 10m pour validation
- **Contrôles zone assignée** : Validation merchandiser
- **Notifications push** : Entrée périmètre, rappels visites

### 📋 Formulaire de Visite Détaillé
- **Section EVAP** : 7 produits (BR Gold, BR 160g, BRB 160g, BR 400g, BRB 400g, Pearl 400g)
- **Section IMP** : 8 produits (BR 400g, BR 900g, BR 2.5Kg, BR 375g, BRB 400g, BR 20g, BRB 25g)
- **Section SCM** : 6 produits (BR 1Kg, BRB 1Kg, BRB 397g, BR 397g, Pearl 1Kg)
- **Sections UHT/YOGHURT** : Présence et prix
- **Statuts standardisés** : "Disponible, Prix respecté", "En rupture", etc.

### 🗺️ Carte Interactive
- **Visualisation PDV** : Markers colorés par type et performance
- **Zones géofencing** : Affichage rayons 300m
- **Filtres avancés** : Par type PDV, secteur, commercial
- **Navigation GPS** : Itinéraires vers PDV

### 💾 Stockage Hybride
- **SQLite local** : Fonctionnement hors-ligne complet
- **Firebase sync** : Synchronisation temps réel
- **Queue de sync** : Reprise automatique des données

## 🏗️ Architecture Technique

### Clean Architecture
```
lib/
├── core/                    # Utilitaires, constantes, services
│   ├── constants/          # Constantes application
│   ├── database/           # Base SQLite
│   ├── services/           # Géofencing, sync
│   ├── themes/             # Thème UI Bonnet Rouge
│   └── utils/              # Dependency injection
├── data/                   # Couche données
│   ├── datasources/        # Firebase, SQLite
│   ├── models/             # Modèles JSON
│   └── repositories/       # Implémentations repo
├── domain/                 # Logique métier
│   ├── entities/           # Entités métier
│   ├── repositories/       # Interfaces repo
│   └── usecases/           # Cas d'usage
└── presentation/           # Interface utilisateur
    ├── bloc/               # State management
    ├── pages/              # Écrans principaux
    └── widgets/            # Widgets réutilisables
```

### Technologies Utilisées
- **Flutter 3.0+** : Framework mobile cross-platform
- **Firebase** : Backend temps réel (Firestore, Auth, Storage)
- **SQLite** : Base données locale
- **BLoC/Provider** : Gestion d'état
- **flutter_map** : Cartes interactives
- **geolocator** : GPS et géofencing
- **fl_chart** : Graphiques analytics

## 📱 Écrans Principaux

1. **Dashboard** : KPI, graphiques, alertes temps réel
2. **Carte** : PDV avec géofencing, navigation
3. **Formulaire Visite** : 5 sections produits, validation GPS
4. **Liste Visites** : Historique, filtres, recherche
5. **Profil** : Stats personnelles, sync, export

## 🔧 Configuration

### Prérequis
- Flutter SDK 3.0+
- Android Studio / Xcode
- Compte Firebase
- API Keys Google Maps

### Installation
```bash
# Clone du repository
git clone [repository-url]
cd frieslandv2

# Installation des dépendances
flutter pub get

# Génération des modèles
flutter packages pub run build_runner build

# Configuration Firebase
# Ajouter google-services.json (Android)
# Ajouter GoogleService-Info.plist (iOS)

# Run application
flutter run
```

### Variables d'environnement
```dart
// lib/core/config/environment.dart
class Environment {
  static const String firebaseProjectId = 'friesland-dashboard';
  static const String googleMapsApiKey = 'YOUR_MAPS_API_KEY';
}
```

## 📊 Modèle de Données

### Table VISITE
- Informations générales : PDV, commercial, géolocalisation
- Produits EVAP : 7 références avec statuts détaillés
- Produits IMP : 8 références avec statuts détaillés
- Produits SCM : 6 références avec statuts détaillés
- UHT/YOGHURT : Présence et prix globaux
- Validation géofencing et précision GPS

### Table PDV
- Identification : Nom, canal, catégorie, sous-catégorie
- Géographie : Région, territoire, zone, secteur, coordonnées
- Configuration : Rayon géofencing (300m par défaut)

### Commerciaux Assignés
- COULIBALY PADIE
- EBROTTIE MIAN CHRISTIAN INNOCENT
- GAI KAMY
- OUATTARA ZANGA
- Guea Hermann

## 🎨 Design System

### Couleurs Bonnet Rouge
- **Primaire** : #E53E3E (Rouge Bonnet Rouge)
- **Secondaire** : #2D3748 (Gris foncé)
- **Succès** : #38A169 (Vert)
- **Attention** : #D69E2E (Orange)
- **Erreur** : #E53E3E (Rouge)

### Typographie
- **Police principale** : Inter (Google Fonts)
- **Police marque** : Bonnet Rouge (custom)

## 🔐 Sécurité

- **Authentification Firebase** : Multi-utilisateurs
- **Permissions géolocalisation** : Demande explicite
- **Validation côté client** : Géofencing obligatoire
- **Chiffrement données** : Transit et stockage

## 📈 Analytics & KPIs

### Métriques Principales
- **Taux présence produits** : % PDV par catégorie
- **Prix respectés** : % conformité tarifaire
- **Performance commerciaux** : Visites/objectifs
- **Couverture géographique** : PDV visités/total

### Exports Disponibles
- **PDF** : Rapports personnalisés
- **Excel** : Données brutes analytics
- **CSV** : Compatible Google Sheets

## 🚀 Déploiement

### Android
```bash
# Build APK
flutter build apk --release

# Build AAB (Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build iOS
flutter build ios --release
```

### Web (Dashboard admin)
```bash
# Build web
flutter build web --release
```

## 📞 Support

Pour tout support technique ou fonctionnel, contactez l'équipe développement Friesland.

---

**Version** : 1.0.0  
**Dernière mise à jour** : 2024  
**Licence** : Propriétaire Friesland