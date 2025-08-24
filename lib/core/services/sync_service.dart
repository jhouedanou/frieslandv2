import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/app_database.dart';
import '../../data/datasources/api_datasource.dart';
import '../../data/models/visite_model.dart';
import '../../data/models/pdv_model.dart';

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
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _onConnectivityChanged(result);
    });
    
    // Démarrer la synchronisation périodique
    _startPeriodicSync();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    
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
      print('Sync error: $e');
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
        print('Erreur sync item ${item['id']}: $e');
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
      final lastSync = await _localDb.getLastSyncTimestamp();
      
      // Synchroniser les PDVs depuis le serveur
      _syncProgress('Synchronisation des PDV...');
      final pdvs = await _apiDataSource.getPDVs();
      
      for (final pdv in pdvs) {
        await _localDb.insertOrUpdatePDV(pdv.toFirestore());
        await _localDb.markAsSynced('pdv', pdv.pdvId);
      }
      
      // Synchroniser les visites récentes
      _syncProgress('Synchronisation des visites récentes...');
      final visites = await _apiDataSource.getVisites();
      
      for (final visite in visites) {
        await _localDb.insertOrUpdateVisite(visite.toFirestore());
        await _localDb.markAsSynced('visites', visite.visiteId);
      }
      
      // Mettre à jour le timestamp de synchronisation
      await _localDb.setLastSyncTimestamp(DateTime.now());
      
    } catch (e) {
      throw Exception('Erreur synchronisation serveur->local: $e');
    }
  }

  // Méthodes pour sauvegarder en local avec queue de sync
  Future<void> saveVisiteOffline(VisiteModel visite, {bool isUpdate = false}) async {
    try {
      final visiteData = visite.toFirestore();
      
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
      return visits.map((data) => VisiteModel.fromFirestore(data)).toList();
    } catch (e) {
      throw Exception('Erreur récupération visites locales: $e');
    }
  }

  Future<List<PDVModel>> getPDVsOffline() async {
    try {
      final pdvs = await _localDb.getPDVs();
      return pdvs.map((data) => PDVModel.fromFirestore(data)).toList();
    } catch (e) {
      throw Exception('Erreur récupération PDV locaux: $e');
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