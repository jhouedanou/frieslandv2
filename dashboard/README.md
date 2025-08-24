# 🎯 Dashboard Friesland - Administration Filament

Dashboard d'administration web séparé et découplé de l'application Flutter mobile, construit avec **Filament 3** et **Laravel 10**.

## 🚀 Fonctionnalités

### 📊 Dashboard Principal
- **Statistiques en temps réel** : PDV, visites, commerciaux
- **Graphiques interactifs** : Évolution des métriques
- **Widgets personnalisés** : Dernières visites, alertes

### 🏪 Gestion des PDV
- **CRUD complet** : Création, modification, suppression
- **Géolocalisation** : Coordonnées GPS, adresses
- **Affectation** : Secteurs, commerciaux assignés
- **Statuts** : Actif, inactif, en rénovation, fermé

### 👥 Gestion des Visites
- **Suivi complet** : Début, fin, durée, géolocalisation
- **Validation GPS** : Contrôle des coordonnées
- **Produits vérifiés** : Sections EVAP, IMP, SCM, UHT, YOGHURT
- **Photos et signatures** : Preuves de visite

### 👤 Gestion des Commerciaux
- **Profils utilisateurs** : Rôles et permissions
- **Activité** : Suivi des performances
- **Sécurité** : Authentification et autorisation

## 🏗️ Architecture

### Technologies
- **Backend** : Laravel 10 + PHP 8.2
- **Admin Panel** : Filament 3
- **Base de données** : PostgreSQL avec PostGIS
- **Cache** : Redis
- **Containerisation** : Docker + Docker Compose

### Structure
```
dashboard/
├── app/
│   ├── Filament/           # Ressources Filament
│   │   ├── Resources/      # CRUD des entités
│   │   ├── Pages/          # Pages personnalisées
│   │   └── Widgets/        # Widgets du dashboard
│   ├── Models/             # Modèles Eloquent
│   ├── Http/               # Contrôleurs et middleware
│   └── Providers/          # Providers Laravel
├── config/                 # Configuration
├── database/               # Migrations et seeders
├── docker/                 # Configuration Docker
└── public/                 # Assets publics
```

## 🚀 Installation et Démarrage

### Prérequis
- Docker et Docker Compose
- PHP 8.2+ (pour développement local)
- Composer (pour développement local)

### 1. Cloner et Configurer
```bash
# Le dashboard est déjà dans le dossier dashboard/
cd dashboard

# Copier le fichier d'environnement
cp env.example .env
```

### 2. Lancer avec Docker
```bash
# Démarrer tous les services
docker-compose up -d

# Le dashboard sera accessible sur http://localhost:8081
```

### 3. Configuration Initiale
```bash
# Générer la clé d'application
docker-compose exec dashboard php artisan key:generate

# Lancer les migrations
docker-compose exec dashboard php artisan migrate

# Créer un utilisateur admin
docker-compose exec dashboard php artisan make:filament-user
```

### 4. Accès au Dashboard
- **URL** : http://localhost:8081/admin
- **Identifiants** : Créés lors de la commande `make:filament-user`

## 🔧 Configuration

### Variables d'Environnement
```env
APP_NAME="Friesland Dashboard"
APP_ENV=production
APP_DEBUG=false
APP_URL=http://localhost:8081

DB_CONNECTION=pgsql
DB_HOST=postgres-local
DB_PORT=5432
DB_DATABASE=friesland_db
DB_USERNAME=friesland_user
DB_PASSWORD=friesland_password

REDIS_HOST=redis-cache
REDIS_PORT=6379
```

### Base de Données
Le dashboard se connecte à la même base PostgreSQL que l'application Flutter :
- **Host** : postgres-local (conteneur Docker)
- **Port** : 5432
- **Base** : friesland_db
- **Utilisateur** : friesland_user

## 📱 Séparation Flutter ↔ Dashboard

### Architecture Découplée
- **Application Flutter** : Interface mobile pour les commerciaux
- **Dashboard Filament** : Interface web d'administration
- **Base de données partagée** : PostgreSQL centralisée
- **API REST** : Communication entre les deux

### Flux de Données
1. **Commerciaux** utilisent l'app Flutter pour les visites
2. **Données** sont synchronisées vers PostgreSQL
3. **Managers** consultent le dashboard Filament
4. **Analytics** et rapports en temps réel

## 🎨 Personnalisation

### Thème et Couleurs
- **Couleurs primaires** : Amber (Friesland)
- **Navigation** : Top navigation + sidebar collapsible
- **Responsive** : Optimisé mobile et desktop

### Widgets Personnalisés
- `StatsOverview` : Métriques principales
- `LatestVisits` : Dernières visites
- `PDVMap` : Carte des points de vente (à venir)

## 🔒 Sécurité

### Authentification
- **Filament Auth** : Système de connexion intégré
- **Rôles et permissions** : Admin, Manager, Supervisor
- **Sessions sécurisées** : Redis + HTTPS

### Autorisation
- **Accès au panel** : Contrôle par rôles
- **Actions CRUD** : Permissions granulaires
- **Données sensibles** : Filtrage par secteur

## 📊 Rapports et Analytics

### Métriques Disponibles
- **PDV** : Total, actifs, par secteur
- **Visites** : Aujourd'hui, cette semaine, ce mois
- **Commerciaux** : Performance, couverture
- **Géolocalisation** : Zones couvertes, distances

### Export de Données
- **CSV** : Rapports détaillés
- **PDF** : Rapports formatés
- **Excel** : Données tabulaires

## 🚀 Déploiement

### Production
```bash
# Build de l'image Docker
docker build -t friesland-dashboard .

# Variables d'environnement de production
APP_ENV=production
APP_DEBUG=false
APP_URL=https://dashboard.friesland.com
```

### Monitoring
- **Logs** : Laravel + Docker
- **Performance** : Redis cache + optimisations
- **Sauvegarde** : Base de données + fichiers

## 🤝 Contribution

### Développement
1. Fork du projet
2. Créer une branche feature
3. Commit des changements
4. Pull Request

### Standards
- **PHP** : PSR-12
- **Laravel** : Best practices officielles
- **Filament** : Guidelines de la documentation

## 📞 Support

- **Documentation** : README et code inline
- **Issues** : GitHub Issues
- **Contact** : Équipe développement Friesland

---

**Dashboard Friesland** - Administration moderne et efficace pour la gestion commerciale 🎯 