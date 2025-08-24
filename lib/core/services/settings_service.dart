import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;
  final StreamController<Map<String, dynamic>> _settingsController = 
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get settingsStream => _settingsController.stream;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _notifyListeners();
  }

  void _notifyListeners() {
    if (_prefs != null) {
      _settingsController.add(_getAllSettings());
    }
  }

  Map<String, dynamic> _getAllSettings() {
    return {
      'syncInterval': syncInterval,
      'autoSync': autoSync,
      'dataRetentionDays': dataRetentionDays,
      'geofenceRadius': geofenceRadius,
      'cacheImages': cacheImages,
      'offlineMode': offlineMode,
      'notificationsEnabled': notificationsEnabled,
      'theme': theme,
      'language': language,
    };
  }

  // Sync Settings
  int get syncInterval => _prefs?.getInt('syncInterval') ?? 15; // minutes
  set syncInterval(int value) {
    _prefs?.setInt('syncInterval', value);
    _notifyListeners();
  }

  bool get autoSync => _prefs?.getBool('autoSync') ?? true;
  set autoSync(bool value) {
    _prefs?.setBool('autoSync', value);
    _notifyListeners();
  }

  int get dataRetentionDays => _prefs?.getInt('dataRetentionDays') ?? 30;
  set dataRetentionDays(int value) {
    _prefs?.setInt('dataRetentionDays', value);
    _notifyListeners();
  }

  // Geofence Settings
  double get geofenceRadius => _prefs?.getDouble('geofenceRadius') ?? 100.0; // meters
  set geofenceRadius(double value) {
    _prefs?.setDouble('geofenceRadius', value);
    _notifyListeners();
  }

  // Cache Settings
  bool get cacheImages => _prefs?.getBool('cacheImages') ?? true;
  set cacheImages(bool value) {
    _prefs?.setBool('cacheImages', value);
    _notifyListeners();
  }

  // Offline Mode
  bool get offlineMode => _prefs?.getBool('offlineMode') ?? false;
  set offlineMode(bool value) {
    _prefs?.setBool('offlineMode', value);
    _notifyListeners();
  }

  // Notifications
  bool get notificationsEnabled => _prefs?.getBool('notificationsEnabled') ?? true;
  set notificationsEnabled(bool value) {
    _prefs?.setBool('notificationsEnabled', value);
    _notifyListeners();
  }

  // Theme
  String get theme => _prefs?.getString('theme') ?? 'system';
  set theme(String value) {
    _prefs?.setString('theme', value);
    _notifyListeners();
  }

  // Language
  String get language => _prefs?.getString('language') ?? 'fr';
  set language(String value) {
    _prefs?.setString('language', value);
    _notifyListeners();
  }

  // API Configuration for Docker
  String get apiBaseUrl => _prefs?.getString('apiBaseUrl') ?? 'http://dashboard:80/api/v1';
  set apiBaseUrl(String value) {
    _prefs?.setString('apiBaseUrl', value);
    _notifyListeners();
  }

  int get apiTimeout => _prefs?.getInt('apiTimeout') ?? 30; // seconds
  set apiTimeout(int value) {
    _prefs?.setInt('apiTimeout', value);
    _notifyListeners();
  }

  // Cache Management
  Future<void> clearCache() async {
    // This would clear image cache, local data cache, etc.
    // Implementation depends on your caching strategy
  }

  Future<void> clearSyncQueue() async {
    // This would clear pending sync operations
    // Implement based on your sync queue implementation
  }

  // Export/Import Settings
  Map<String, dynamic> exportSettings() {
    return _getAllSettings();
  }

  Future<void> importSettings(Map<String, dynamic> settings) async {
    if (_prefs == null) return;

    for (final entry in settings.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is bool) {
        await _prefs!.setBool(key, value);
      } else if (value is int) {
        await _prefs!.setInt(key, value);
      } else if (value is double) {
        await _prefs!.setDouble(key, value);
      } else if (value is String) {
        await _prefs!.setString(key, value);
      }
    }

    _notifyListeners();
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    if (_prefs == null) return;

    final keys = [
      'syncInterval', 'autoSync', 'dataRetentionDays',
      'geofenceRadius', 'cacheImages', 'offlineMode',
      'notificationsEnabled', 'theme', 'language',
      'apiBaseUrl', 'apiTimeout'
    ];

    for (final key in keys) {
      await _prefs!.remove(key);
    }

    _notifyListeners();
  }

  // Storage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    // Get information about local storage usage
    // This is a placeholder - implement based on your storage strategy
    return {
      'totalVisites': 0,
      'totalPDVs': 0,
      'totalImages': 0,
      'syncQueueSize': 0,
      'lastSync': null,
    };
  }

  void dispose() {
    _settingsController.close();
  }
}