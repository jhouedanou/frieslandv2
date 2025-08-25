import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/app_database.dart';
import '../../data/datasources/api_datasource.dart';
import '../../data/models/visite_model.dart';
import '../../data/models/pdv_model.dart';
import '../../data/mock_pdvs.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final AppDatabase _localDb = AppDatabase();
  late final ApiDataSource _apiDataSource;
  late final Connectivity _connectivity;
  
  bool _isOnline = false;
  bool _isSyncing = false;
  Timer? _syncTimer;
  
  // Streams pour notifier les changements
  final StreamController<bool> _syncStatusController = StreamController<bool>.broadcast();
  final StreamController<String> _syncProgressController = StreamController<String>.broadcast();
  
  Stream<bool> get syncStatus => _syncStatusController.stream;
  Stream<String> get syncProgress => _syncProgressController.stream;
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  Future<void> initialize(ApiDataSource apiDataSource, Connectivity connectivity) async {
    _apiDataSource = apiDataSource;
    _connectivity = connectivity;
    
    // Vérifier la connexion initiale
    await _checkConnectivity();
    
    // Écouter les changements de connectivité
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _onConnectivityChanged(results.isNotEmpty ? results.first : ConnectivityResult.none);
    });
    
    // Démarrer la synchronisation périodique
    _startPeriodicSync();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    _isOnline = connectivityResults.isNotEmpty && !connectivityResults.contains(ConnectivityResult.none);
    
    if (_isOnline) {
      // Tenter de synchroniser au démarrage
      _syncData();
    }
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    if (!wasOnline && _isOnline) {
      // Connexion rétablie, synchroniser
      _syncProgress('Connexion rétablie - Synchronisation...');
      _syncData();
    }
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      if (_isOnline && !_isSyncing) {
        _syncData();
      }
    });
  }

  Future<void> _syncData() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    _syncStatusController.add(true);
    
    try {
      _syncProgress('Synchronisation des données...');
      
      // Synchroniser les données locales vers le serveur
      await _syncLocalToServer();
      
      // Synchroniser les données serveur vers local
      await _syncServerToLocal();
      
      _syncProgress('Synchronisation terminée');
      
    } catch (e) {
      _syncProgress('Erreur de synchronisation: $e');
      // Log sync error: $e
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  Future<void> _syncLocalToServer() async {
    // Récupérer les éléments non synchronisés de la queue
    final syncQueue = await _localDb.getSyncQueue();
    
    for (final item in syncQueue) {
      try {
        final tableName = item['table_name'] as String;
        final recordId = item['record_id'] as String;
        final operation = item['operation'] as String;
        final dataJson = item['data'] as String;
        final data = jsonDecode(dataJson);
        
        switch (tableName) {
          case 'visites':
            await _syncVisiteToServer(recordId, operation, data);
            break;
          case 'pdvs':
            await _syncPDVToServer(recordId, operation, data);
            break;
        }
        
        // Supprimer de la queue après synchronisation réussie
        await _localDb.removeSyncQueueItem(item['id'] as int);
        
      } catch (e) {
        // Log erreur sync item ${item['id']}: $e
        // Laisser dans la queue pour réessayer plus tard
      }
    }
  }

  Future<void> _syncVisiteToServer(String recordId, String operation, Map<String, dynamic> data) async {
    switch (operation) {
      case 'CREATE':
      case 'UPDATE':
        final visite = VisiteModel.fromJson(data);
        if (operation == 'CREATE') {
          await _apiDataSource.createVisite(visite);
        } else {
          await _apiDataSource.updateVisite(visite);
        }
        break;
      case 'DELETE':
        await _apiDataSource.deleteVisite(recordId);
        break;
    }
  }

  Future<void> _syncPDVToServer(String recordId, String operation, Map<String, dynamic> data) async {
    // Implémentation pour PDV si nécessaire
    // Pour l'instant, les PDV sont généralement créés côté serveur uniquement
  }

  Future<void> _syncServerToLocal() async {
    try {
      // Obtenir le timestamp de la dernière synchronisation
      await _localDb.getLastSyncTimestamp();
      
      // Synchroniser les PDVs depuis le serveur
      _syncProgress('Synchronisation des PDV...');
      final pdvs = await _apiDataSource.getPDVs();
      
      for (final pdv in pdvs) {
        await _localDb.insertOrUpdatePDV(pdv.toJson());
        await _localDb.markAsSynced('pdv', pdv.pdvId);
      }
      
      // Synchroniser les visites récentes
      _syncProgress('Synchronisation des visites récentes...');
      final visites = await _apiDataSource.getVisites();
      
      for (final visite in visites) {
        await _localDb.insertOrUpdateVisite(visite.toJson());
        await _localDb.markAsSynced('visites', visite.visiteId);
      }
      
      // Mettre à jour le timestamp de synchronisation
      await _localDb.setLastSyncTimestamp(DateTime.now());
      
    } catch (e) {
      throw Exception('Erreur synchronisation serveur->local: $e');
    }
  }

  // Méthodes pour sauvegarder en local avec queue de sync selon CLAUDE.md
  Future<void> saveVisiteOffline(VisiteModel visite, {bool isUpdate = false}) async {
    try {
      final visiteData = visite.toJson(); // Utilise toJson() au lieu de toFirestore()
      
      if (isUpdate) {
        await _localDb.updateVisite(visite.visiteId, visiteData);
        await _localDb.addToSyncQueue('visites', visite.visiteId, 'UPDATE', visiteData);
      } else {
        await _localDb.insertVisite(visiteData);
        await _localDb.addToSyncQueue('visites', visite.visiteId, 'CREATE', visiteData);
      }
      
      // Si en ligne, essayer de synchroniser immédiatement
      if (_isOnline && !_isSyncing) {
        _syncData();
      }
      
    } catch (e) {
      throw Exception('Erreur sauvegarde locale: $e');
    }
  }

  Future<List<VisiteModel>> getVisitesOffline() async {
    try {
      final visits = await _localDb.getVisites();
      return visits.map((data) => VisiteModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Erreur récupération visites locales: $e');
    }
  }

  Future<List<PDVModel>> getPDVsOffline() async {
    try {
      // Récupérer les PDVs fictifs créés pour l'utilisateur connecté
      final fictionalPDVs = MockPDVs.getFictionalPDVs();
      
      // Convertir en PDVModel pour compatibilité
      final pdvModels = fictionalPDVs.map((pdv) => PDVModel(
        pdvId: pdv.pdvId,
        nomPdv: pdv.nomPdv,
        canal: pdv.canal,
        categoriePdv: pdv.categoriePdv,
        sousCategoriePdv: pdv.sousCategoriePdv,
        region: pdv.region,
        territoire: pdv.territoire,
        zone: pdv.zone,
        secteur: pdv.secteur,
        latitude: pdv.latitude,
        longitude: pdv.longitude,
        rayonGeofence: pdv.rayonGeofence,
        adressage: pdv.adressage,
        dateCreation: pdv.dateCreation,
        ajoutePar: pdv.ajoutePar,
        mdm: pdv.mdm,
      )).toList();
      
      print('✅ Chargé ${pdvModels.length} PDVs fictifs pour l\'utilisateur connecté');
      print('🎯 PDV principal: ${pdvModels.first.nomPdv}');
      print('📍 Coordonnées exactes: ${pdvModels.first.latitude}, ${pdvModels.first.longitude}');
      
      return pdvModels;
    } catch (e) {
      print('Erreur getPDVsOffline: $e');
      // Fallback - essayer la base locale
      try {
        final pdvs = await _localDb.getPDVs();
        return pdvs.map((data) => PDVModel.fromJson(data)).toList();
      } catch (e2) {
        throw Exception('Erreur récupération PDV locaux: $e2');
      }
    }
  }

  // Forcer la synchronisation
  Future<void> forcSync() async {
    if (_isOnline) {
      await _syncData();
    } else {
      throw Exception('Aucune connexion internet disponible');
    }
  }

  void _syncProgress(String message) {
    _syncProgressController.add(message);
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
    _syncProgressController.close();
  }
}