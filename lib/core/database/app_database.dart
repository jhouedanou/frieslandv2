import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'friesland_database.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create VISITE table
    await db.execute('''
      CREATE TABLE visites (
        visite_id TEXT PRIMARY KEY,
        pdv_id TEXT NOT NULL,
        nom_du_pdv TEXT NOT NULL,
        date_visite INTEGER NOT NULL,
        commercial TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        distance_au_pdv REAL NOT NULL,
        mdm TEXT NOT NULL,
        image_path TEXT,
        geofence_valide INTEGER NOT NULL,
        precision_gps REAL NOT NULL,
        evap_present INTEGER NOT NULL,
        evap_br_gold_present TEXT,
        evap_br_160g_present TEXT,
        evap_brb_160g_present TEXT,
        evap_br_400g_present TEXT,
        evap_brb_400g_present TEXT,
        evap_pearl_400g_present TEXT,
        evap_prix_respectes INTEGER NOT NULL,
        imp_present INTEGER NOT NULL,
        imp_br_400g_present TEXT,
        imp_br_900g_present TEXT,
        imp_br_2_5kg_present TEXT,
        imp_br_375g_present TEXT,
        imp_brb_400g_present TEXT,
        imp_br_20g_present TEXT,
        imp_brb_25g_present TEXT,
        imp_prix_respectes INTEGER NOT NULL,
        scm_present INTEGER NOT NULL,
        scm_br_1kg_present TEXT,
        scm_brb_1kg_present TEXT,
        scm_brb_397g_present TEXT,
        scm_br_397g_present TEXT,
        scm_pearl_1kg_present TEXT,
        scm_prix_respectes INTEGER NOT NULL,
        uht_present INTEGER NOT NULL,
        uht_prix_respectes INTEGER NOT NULL,
        yoghurt_present INTEGER NOT NULL,
        yoghurt_prix_respectes INTEGER NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create PDV table
    await db.execute('''
      CREATE TABLE pdv (
        pdv_id TEXT PRIMARY KEY,
        nom_pdv TEXT NOT NULL,
        canal TEXT NOT NULL,
        categorie_pdv TEXT NOT NULL,
        sous_categorie_pdv TEXT NOT NULL,
        autre_sous_categorie TEXT,
        region TEXT NOT NULL,
        territoire TEXT NOT NULL,
        zone TEXT NOT NULL,
        secteur TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        rayon_geofence REAL NOT NULL DEFAULT 300.0,
        adressage TEXT NOT NULL,
        image_path TEXT,
        date_creation INTEGER NOT NULL,
        ajoute_par TEXT NOT NULL,
        mdm TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create MERCHANDISER table
    await db.execute('''
      CREATE TABLE merchandisers (
        merchandiser_id TEXT PRIMARY KEY,
        nom TEXT NOT NULL,
        email TEXT NOT NULL,
        telephone TEXT NOT NULL,
        zone_assignee TEXT NOT NULL,
        secteurs_assignes TEXT NOT NULL,
        zone_geofence TEXT,
        is_synced INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create sync queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_visites_commercial ON visites(commercial)');
    await db.execute('CREATE INDEX idx_visites_date ON visites(date_visite)');
    await db.execute('CREATE INDEX idx_visites_pdv_id ON visites(pdv_id)');
    await db.execute('CREATE INDEX idx_pdv_secteur ON pdv(secteur)');
    await db.execute('CREATE INDEX idx_pdv_zone ON pdv(zone)');
    await db.execute('CREATE INDEX idx_sync_queue_table ON sync_queue(table_name)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // Visite operations
  Future<int> insertVisite(Map<String, dynamic> visite) async {
    final db = await database;
    visite['created_at'] = DateTime.now().millisecondsSinceEpoch;
    visite['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.insert('visites', visite);
  }

  Future<List<Map<String, dynamic>>> getVisites() async {
    final db = await database;
    return await db.query('visites', orderBy: 'date_visite DESC');
  }

  Future<List<Map<String, dynamic>>> getVisitesByCommercial(String commercial) async {
    final db = await database;
    return await db.query(
      'visites',
      where: 'commercial = ?',
      whereArgs: [commercial],
      orderBy: 'date_visite DESC',
    );
  }

  Future<int> updateVisite(String visiteId, Map<String, dynamic> visite) async {
    final db = await database;
    visite['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update(
      'visites',
      visite,
      where: 'visite_id = ?',
      whereArgs: [visiteId],
    );
  }

  // PDV operations
  Future<int> insertPDV(Map<String, dynamic> pdv) async {
    final db = await database;
    pdv['created_at'] = DateTime.now().millisecondsSinceEpoch;
    pdv['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.insert('pdv', pdv);
  }

  Future<List<Map<String, dynamic>>> getPDVs() async {
    final db = await database;
    return await db.query('pdv', orderBy: 'nom_pdv ASC');
  }

  Future<List<Map<String, dynamic>>> getPDVsBySecteur(String secteur) async {
    final db = await database;
    return await db.query(
      'pdv',
      where: 'secteur = ?',
      whereArgs: [secteur],
      orderBy: 'nom_pdv ASC',
    );
  }

  // Sync operations
  Future<int> addToSyncQueue(String tableName, String recordId, String operation, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('sync_queue', {
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation,
      'data': data.toString(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'created_at ASC');
  }

  Future<int> removeSyncQueueItem(int id) async {
    final db = await database;
    return await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  // Analytics queries
  Future<Map<String, int>> getProductPresenceStats() async {
    final db = await database;
    
    final evapCount = await db.rawQuery('SELECT COUNT(*) as count FROM visites WHERE evap_present = 1');
    final impCount = await db.rawQuery('SELECT COUNT(*) as count FROM visites WHERE imp_present = 1');
    final scmCount = await db.rawQuery('SELECT COUNT(*) as count FROM visites WHERE scm_present = 1');
    final uhtCount = await db.rawQuery('SELECT COUNT(*) as count FROM visites WHERE uht_present = 1');
    final yoghurtCount = await db.rawQuery('SELECT COUNT(*) as count FROM visites WHERE yoghurt_present = 1');
    final totalCount = await db.rawQuery('SELECT COUNT(*) as count FROM visites');
    
    final total = totalCount.first['count'] as int;
    if (total == 0) return {};

    return {
      'evap': ((evapCount.first['count'] as int) * 100 / total).round(),
      'imp': ((impCount.first['count'] as int) * 100 / total).round(),
      'scm': ((scmCount.first['count'] as int) * 100 / total).round(),
      'uht': ((uhtCount.first['count'] as int) * 100 / total).round(),
      'yoghurt': ((yoghurtCount.first['count'] as int) * 100 / total).round(),
    };
  }

  Future<Map<String, int>> getCommercialStats() async {
    final db = await database;
    
    final results = await db.rawQuery('''
      SELECT commercial, COUNT(*) as count 
      FROM visites 
      GROUP BY commercial 
      ORDER BY count DESC
    ''');
    
    final Map<String, int> stats = {};
    for (final row in results) {
      stats[row['commercial'] as String] = row['count'] as int;
    }
    
    return stats;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}