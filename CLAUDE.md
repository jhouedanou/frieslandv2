# Instructions pour Claude Code - Application Friesland Bonnet Rouge

## Vue d'ensemble du projet

Créer une **application mobile Flutter** de collecte de données terrain + **API Laravel** + **Dashboard Filament** pour remplacer le système AppSheet actuel de Friesland Bonnet Rouge.

### Architecture technique
```
App Mobile Flutter ↔ API REST Laravel ↔ Dashboard Filament
     ↓                    ↓                    ↓
   SQLite           MySQL/PostgreSQL      Interface Admin
   Géofencing       Queue Jobs           Widgets KPI
   Hors-ligne       WebSockets          Graphiques
```

## 🎯 Objectifs principaux

1. **App Mobile Flutter** : Collecte données visites PDV par merchandisers
2. **API Laravel** : Backend REST avec authentification JWT
3. **Dashboard Filament** : Interface admin avec métriques temps réel
4. **Géofencing** : Validation 300m des PDV obligatoire
5. **Mode hors-ligne** : Synchronisation différée des données

## 📱 App Mobile Flutter - Spécifications détaillées

### Structure des écrans
1. **Écran d'accueil** : Liste vide avec bouton "+" (nouvelle visite)
2. **Sélection PDV** : Choix point de vente à visiter
3. **Validation géofencing** : Contrôle 300m du PDV
4. **Formulaire multi-onglets** : 4 sections progressives
5. **Capture photo** : Documentation visuelle obligatoire
6. **Synchronisation** : Upload vers API Laravel

### Formulaire multi-onglets détaillé

#### Onglet 1 - "Général" (Disponibilité et Prix)
- **EVAP Présent** : OUI/NON
  - Si OUI → sous-formulaire :
    * BR Gold (En rupture/Présent + bouton)
    * BR 150g (En rupture/Présent + bouton)
    * BRB 150g (En rupture/Présent + bouton)
    * BR 380g (En rupture/Présent + bouton)
    * BRB 380g (En rupture/Présent + bouton)
    * Pearl 380g (En rupture/Présent + bouton)

- **IMP Présent** : OUI/NON
  - Si OUI → sous-formulaire :
    * BR 2 (En rupture/Présent + bouton)
    * BR 16g (En rupture/Présent + bouton)
    * BRB 16g (En rupture/Présent + bouton)
    * BR 360g (En rupture/Présent + bouton)
    * BR 400g Tin (En rupture/Présent + bouton)
    * BRB 360g (En rupture/Présent + bouton)
    * BR 900g Tin (En rupture/Présent + bouton)
    * Prix respectés? (OUI/NON)

- **SCM Présent** : OUI/NON
  - Si OUI → sous-formulaire produits + Prix respectés? (OUI/NON)

- **UHT Présent** : OUI/NON
  - Si OUI → sous-formulaire produits + Prix respectés? (OUI/NON)

- **YAOURT Présent** : OUI/NON

#### Onglet 2 - "Concurrence"
- **Présence de concurrents** : OUI/NON
- Si OUI, détail par marque :
  * **Concurrent EVAP** : Cowmilk, NIDO 150g, autre (En rupture/Présent)
  * **Concurrent IMP** : Nido, Laity, autre (En rupture/Présent)
  * **Concurrent SCM** : Top Saho, autre (En rupture/Présent) + nom concurrent (texte libre)
  * **Concurrent UHT** : OUI/NON

#### Onglet 3 - "Visibilité"
- **Visibilité intérieure** : Présence de visibilité intérieure (OUI/NON)
- **Visibilité concurrence** :
  * Présence générale (OUI/NON)
  * NIDO extérieur/intérieur (OUI/NON)
  * LAITY extérieur/intérieur (OUI/NON)
  * CANDIA extérieur/intérieur (OUI/NON)

#### Onglet 4 - "Actions"
- 7 actions terrain avec toggles OUI/NON :
  * Référencement produits
  * Exécution d'activités promotionnelles
  * Prospection PDV
  * Vérification FIFO
  * Rangement produits
  * Pose d'affiches
  * Pose matériel de visibilité

### Interface utilisateur
- **Navigation** : PageView avec indicateur progression
- **Boutons état** : Toggle rouge NON/rouge OUI
- **Validation** : Champs obligatoires (*) par onglet
- **Navigation** : Prev/Cancel/Next/Save
- **Thème** : Material Design rouge Bonnet Rouge

### Géofencing
- **Rayon** : 300m maximum du PDV
- **Validation** : Avant accès formulaire + durant remplissage
- **GPS** : Précision minimum 10m
- **Fallback** : Géolocalisation réseau si GPS indisponible

### Stockage local
- **SQLite** : Données hors-ligne avec queue sync
- **Hive** : Cache rapide pour configuration
- **Images** : Compression automatique avant upload

## 🔧 API Laravel - Backend REST

### Modèles Eloquent
```php
// app/Models/Visite.php
- id, visite_id (UUID), pdv_id, commercial, date_visite
- geolocation (lat/lng), geofence_validated, precision_gps
- produits (JSON), concurrence (JSON), visibilite (JSON), actions (JSON)
- images (JSON array), sync_status, created_at, updated_at

// app/Models/PDV.php  
- id, pdv_id (UUID), nom_pdv, canal, categorie_pdv, sous_categorie_pdv
- region, territoire, zone, secteur, geolocation (lat/lng)
- rayon_geofence (default 300), adressage, image, date_creation
- ajoute_par, mdm

// app/Models/Commercial.php
- id, nom, email, telephone, zone_assignee, secteurs_assignes (JSON)
- zone_geofence (GeoJSON), created_at, updated_at
```

### Routes API
```php
// routes/api.php
POST /api/auth/login          // Authentification JWT
GET  /api/pdv                 // Liste PDV par zone
GET  /api/pdv/{id}           // Détail PDV avec géofencing
POST /api/visites            // Création nouvelle visite
PUT  /api/visites/{id}       // Mise à jour visite
GET  /api/commerciaux/me     // Profil utilisateur connecté
POST /api/images/upload      // Upload photos
GET  /api/dashboard/stats    // Métriques pour dashboard
```

### Structure JSON pour visites
```json
{
  "visite_id": "uuid",
  "pdv_id": "uuid", 
  "commercial": "nom_merchandiser",
  "date": "2024-01-03T10:15:30Z",
  "geolocation": {"lat": 5.123, "lng": -4.567},
  "geofence_validated": true,
  "produits": {
    "evap": {
      "present": true,
      "br_gold": "En rupture|Présent",
      "br_150g": "En rupture|Présent", 
      "brb_150g": "En rupture|Présent",
      "br_380g": "En rupture|Présent",
      "brb_380g": "En rupture|Présent",
      "pearl_380g": "En rupture|Présent"
    },
    "imp": {
      "present": true,
      "prix_respectes": true,
      // ... détail produits IMP
    },
    "scm": {
      "present": false,
      "prix_respectes": true,
      // ... détail produits SCM
    },
    "uht": {
      "present": true,
      "prix_respectes": false,
      // ... détail produits UHT
    },
    "yaourt": {
      "present": false
    }
  },
  "concurrence": {
    "presence_concurrents": true,
    "evap": {
      "present": true,
      "cowmilk": "En rupture|Présent",
      "nido_150g": "En rupture|Présent", 
      "autre": "En rupture|Présent"
    },
    // ... autres catégories concurrence
  },
  "visibilite": {
    "interieure": {"presence_visibilite": true},
    "concurrence": {
      "presence_visibilite": false,
      "nido_exterieur": false,
      "nido_interieur": false,
      "laity_exterieur": false, 
      "laity_interieur": false,
      "candia_exterieur": false,
      "candia_interieur": false
    }
  },
  "actions": {
    "referencement_produits": true,
    "execution_activites_promotionnelles": false,
    "prospection_pdv": true,
    "verification_fifo": false,
    "rangement_produits": true,
    "pose_affiches": false,
    "pose_materiel_visibilite": true
  },
  "images": ["base64_encoded_images"],
  "sync_status": "synced|pending|failed"
}
```

### Middleware et Services
- **AuthController** : Login JWT avec Laravel Sanctum
- **GeofencingService** : Validation distance PDV
- **SyncService** : Queue Jobs pour traitement données
- **ImageService** : Upload et compression photos

## 📊 Dashboard Filament - Interface Admin

### Widgets KPI basés sur données réelles
- **Total Visites** : Count des enregistrements
- **Taux présence produits** :
  * % PDV avec EVAP présent
  * % PDV avec IMP présent  
  * % PDV avec SCM présent
  * % UHT présent
  * % YAOURT présent
- **Taux respect prix** par catégorie (EVAP, IMP, SCM)
- **Performance commerciaux** : COULIBALY PADIE, EBROTTIE MIAN, GAI KAMY, etc.

### Ressources Filament
```php
// app/Filament/Resources/VisiteResource.php
- Table avec toutes colonnes Google Sheets
- Filtres par date, commercial, PDV, produit
- Actions export PDF/Excel
- Relation avec PDV et Commercial

// app/Filament/Resources/PDVResource.php
- Gestion CRUD points de vente
- Carte interactive avec géofencing
- Import/export masse

// app/Filament/Resources/CommercialResource.php  
- Gestion merchandisers avec zones assignées
- Performance individuelle avec métriques

// app/Filament/Pages/Dashboard.php
- Widgets Chart.js pour graphiques
- KPI temps réel avec WebSockets
- Rapports personnalisés
```

### Graphiques Chart.js intégrés
- Évolution temporelle visites
- Performance par commercial  
- Distribution par type PDV
- Analyse produits par statut ("Disponible , Prix respecté", "En rupture")

## 🚀 Priorités de développement

### Phase 1 - Backend Laravel (priorité)
1. **Setup Laravel** : Installation + configuration base
2. **Modèles Eloquent** : Visite, PDV, Commercial avec migrations
3. **API REST** : Endpoints authentication + CRUD visites
4. **Middleware** : JWT auth + validation géofencing
5. **Tests** : Unit tests pour API endpoints

### Phase 2 - Dashboard Filament
1. **Installation Filament** : Configuration admin panel
2. **Ressources** : CRUD Visites, PDV, Commerciaux
3. **Widgets** : KPI dashboard avec métriques temps réel
4. **Graphiques** : Chart.js intégration
5. **Exports** : PDF/Excel des rapports

### Phase 3 - App Mobile Flutter
1. **Setup Flutter** : Configuration + dépendances
2. **Authentification** : Login avec API Laravel
3. **Géofencing** : Service validation 300m PDV
4. **Formulaires** : Multi-onglets avec validation
5. **Synchronisation** : Mode hors-ligne + API calls
6. **Interface** : Thème Bonnet Rouge + UX optimisée

## 📦 Dépendances techniques

### Laravel Backend
```json
{
  "laravel/framework": "^10.0",
  "filament/filament": "^3.0",
  "laravel/sanctum": "^3.0",
  "maatwebsite/excel": "^3.1",
  "barryvdh/laravel-dompdf": "^2.0",
  "pusher/pusher-php-server": "^7.2"
}
```

### Flutter Mobile
```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0                    # HTTP client
  geolocator: ^10.1.0           # GPS/Géofencing
  geofence_service: ^5.2.0      # Géofencing background
  hive_flutter: ^1.1.0          # Cache local
  sqflite: ^2.3.0               # Base données locale
  image_picker: ^1.0.4          # Capture photos
  provider: ^6.1.1              # State management
  flutter_map: ^6.1.0           # Cartes
```

## 🔒 Sécurité et Permissions

### Authentification
- **JWT tokens** Laravel Sanctum
- **Refresh tokens** automatique
- **Permissions** par zone géographique
- **Rate limiting** sur API endpoints

### Géofencing
- **Validation obligatoire** 300m PDV
- **Historique GPS** pour audit
- **Mode dégradé** si GPS indisponible
- **Consentement utilisateur** tracking

### Données
- **Chiffrement** données sensibles
- **RGPD compliant** avec opt-out
- **Backup** automatique quotidien
- **Logs** détaillés pour debugging

## 📝 Standards de développement

### Code Quality
- **PSR-12** standards PHP Laravel
- **Dart/Flutter** conventions officielles  
- **Tests unitaires** coverage >80%
- **Documentation** inline + README

### Git Workflow
- **Feature branches** pour nouvelles fonctionnalités
- **Pull requests** avec review obligatoire
- **Semantic versioning** pour releases
- **CI/CD** automatisé avec GitHub Actions

### Performance
- **Lazy loading** relations Eloquent
- **Query optimization** avec DB indexes
- **Image compression** côté mobile
- **Caching** Redis pour métriques dashboard

## 🎯 Livrables attendus

1. **API Laravel** : Backend REST complet avec documentation
2. **Dashboard Filament** : Interface admin avec tous les KPI
3. **App Mobile Flutter** : Application terrain avec géofencing
4. **Documentation** : Installation, utilisation, API endpoints
5. **Tests** : Suite de tests automatisés
6. **Docker** : Configuration conteneurs pour déploiement

## 📋 Format données compatible

Le système doit produire des données **identiques** au Google Sheets actuel :
- **Même structure** colonnes et format
- **Même nommage** commerciaux et produits  
- **Export Excel** avec mise en forme
- **Migration** progressive depuis AppSheet

Commencer par le **backend Laravel + Filament** puis l'**app Flutter** en dernier.