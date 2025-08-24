# Documentation API Friesland Dashboard

## Vue d'ensemble

L'API Friesland Dashboard permet à l'application Flutter de communiquer avec le système de gestion des PDV et visites. L'API est conçue pour fonctionner en mode hors ligne avec synchronisation automatique.

## Base URL

```
https://votre-domaine.com/api/v1
```

## Authentification

L'API utilise Laravel Sanctum pour l'authentification. Tous les endpoints protégés nécessitent un token Bearer.

### Connexion

```http
POST /api/auth/login
```

**Body:**
```json
{
    "email": "user@example.com",
    "password": "password",
    "device_name": "Flutter App"
}
```

**Réponse:**
```json
{
    "user": {
        "id": 1,
        "name": "John Doe",
        "email": "user@example.com",
        "role": "commercial"
    },
    "token": "1|abc123...",
    "token_type": "Bearer",
    "expires_at": "2024-02-01T00:00:00.000000Z"
}
```

### Utilisation du token

Ajoutez le header suivant à toutes les requêtes authentifiées :

```http
Authorization: Bearer 1|abc123...
```

## Endpoints principaux

### 1. PDV (Points de Vente)

#### Lister les PDV
```http
GET /api/v1/pdvs
```

**Paramètres de filtrage:**
- `secteur`: Filtrer par secteur
- `type_pdv`: Filtrer par type
- `statut`: Filtrer par statut
- `commercial_id`: Filtrer par commercial
- `search`: Recherche textuelle

#### PDV à proximité
```http
GET /api/v1/pdvs/nearby?latitude=48.8566&longitude=2.3522&radius=5
```

### 2. Visites

#### Créer une visite
```http
POST /api/v1/visites
```

**Body:**
```json
{
    "pdv_id": 1,
    "commercial_id": 1,
    "date_visite": "2024-01-15",
    "statut": "en_cours",
    "notes": "Visite de routine"
}
```

#### Démarrer une visite
```http
POST /api/v1/visites/start
```

**Body:**
```json
{
    "visite_id": 1,
    "latitude": 48.8566,
    "longitude": 2.3522,
    "timestamp": "2024-01-15T10:00:00Z"
}
```

#### Terminer une visite
```http
POST /api/v1/visites/end
```

**Body:**
```json
{
    "visite_id": 1,
    "latitude": 48.8566,
    "longitude": 2.3522,
    "timestamp": "2024-01-15T11:30:00Z",
    "notes": "Visite terminée avec succès"
}
```

### 3. Synchronisation hors ligne

#### Vérifier l'état de synchronisation
```http
GET /api/v1/sync/check?last_sync=2024-01-01T00:00:00Z
```

#### Télécharger les données mises à jour
```http
GET /api/v1/sync/download?last_sync=2024-01-01T00:00:00Z&data_types[]=pdvs&data_types[]=visites
```

#### Upload des données hors ligne
```http
POST /api/v1/sync/upload
```

**Body:**
```json
{
    "data": {
        "visites": [
            {
                "pdv_id": 1,
                "commercial_id": 1,
                "date_visite": "2024-01-15",
                "statut": "terminee",
                "notes": "Visite effectuée hors ligne"
            }
        ]
    },
    "device_id": "flutter-app-001",
    "sync_timestamp": "2024-01-15T12:00:00Z"
}
```

### 4. Géofences

#### Vérifier la position
```http
POST /api/v1/geofences/check
```

**Body:**
```json
{
    "latitude": 48.8566,
    "longitude": 2.3522,
    "pdv_id": 1
}
```

#### Entrer dans une zone
```http
POST /api/v1/geofences/enter
```

**Body:**
```json
{
    "pdv_id": 1,
    "latitude": 48.8566,
    "longitude": 2.3522,
    "timestamp": "2024-01-15T10:00:00Z"
}
```

### 5. Analytics

#### Tableau de bord
```http
GET /api/v1/analytics/dashboard
```

#### Statistiques des visites
```http
GET /api/v1/analytics/visites?period=month
```

## Gestion du mode hors ligne

### Stratégie de synchronisation

1. **Vérification automatique**: L'app vérifie la connectivité toutes les 5 minutes
2. **Synchronisation différée**: Les données créées hors ligne sont stockées localement
3. **Résolution des conflits**: L'API gère automatiquement les conflits de synchronisation
4. **Synchronisation intelligente**: Seules les données modifiées sont synchronisées

### Stockage local

L'app Flutter doit implémenter un stockage local pour :

- PDV assignés
- Visites en cours
- Données de géolocalisation
- Photos et signatures
- Cache des produits et prix

### Exemple de flux de synchronisation

```dart
class SyncService {
  Future<void> syncData() async {
    try {
      // 1. Vérifier l'état de synchronisation
      final syncStatus = await api.checkSync(lastSyncTimestamp);
      
      if (syncStatus.hasChanges) {
        // 2. Télécharger les mises à jour
        final updates = await api.downloadUpdates(lastSyncTimestamp);
        await localDatabase.updateData(updates);
        
        // 3. Upload des données locales
        final localData = await localDatabase.getUnsyncedData();
        if (localData.isNotEmpty) {
          await api.uploadData(localData);
        }
        
        // 4. Mettre à jour le timestamp de synchronisation
        lastSyncTimestamp = DateTime.now();
      }
    } catch (e) {
      // Gérer les erreurs de synchronisation
      await queueSyncTask();
    }
  }
}
```

## Gestion des erreurs

### Codes d'erreur HTTP

- `400`: Données invalides
- `401`: Non authentifié
- `403`: Non autorisé
- `404`: Ressource non trouvée
- `422`: Erreur de validation
- `500`: Erreur serveur

### Format des erreurs

```json
{
    "message": "Erreur de validation",
    "errors": {
        "email": ["L'email doit être valide"],
        "password": ["Le mot de passe est requis"]
    }
}
```

## Rate Limiting

L'API limite les requêtes à 60 par minute par utilisateur pour les endpoints authentifiés.

## Webhooks

L'API peut envoyer des webhooks pour :

- Entrée/sortie de géofence
- Fin de visite
- Mise à jour de PDV

### Configuration des webhooks

```http
POST /api/v1/webhooks/configure
```

**Body:**
```json
{
    "url": "https://votre-app.com/webhook",
    "events": ["geofence", "visit_complete"],
    "secret": "webhook_secret_key"
}
```

## Tests

### Endpoint de santé
```http
GET /api/health
```

### Test d'authentification
```http
GET /api/v1/users/profile
```

## Support

Pour toute question concernant l'API, contactez l'équipe technique Friesland.

---

**Version**: 1.0.0  
**Dernière mise à jour**: Janvier 2024 