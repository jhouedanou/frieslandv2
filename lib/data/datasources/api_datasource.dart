import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/visite_model.dart';
import '../models/pdv_model.dart';
import '../../core/constants/app_constants.dart';

abstract class ApiDataSource {
  // Authentication
  Future<Map<String, dynamic>> login(String email, String password, String deviceName);
  Future<void> logout();
  void setAuthToken(String token);
  
  // Visits
  Future<List<VisiteModel>> getVisites();
  Future<List<VisiteModel>> getVisitesByCommercial(String commercial);
  Future<VisiteModel> createVisite(VisiteModel visite);
  Future<VisiteModel> updateVisite(VisiteModel visite);
  Future<void> deleteVisite(String visiteId);
  
  // PDVs  
  Future<List<PDVModel>> getPDVs();
  Future<List<PDVModel>> getPDVsBySecteur(String secteur);
  Future<List<PDVModel>> getNearbyPDVs(double lat, double lng, {double radius = 5000});
  
  // Analytics
  Future<Map<String, dynamic>> getDashboardAnalytics();
  Future<Map<String, dynamic>> getCommercialStats(String commercial);
  
  // Sync
  Future<Map<String, dynamic>> checkSync({String? lastSync});
  Future<Map<String, dynamic>> downloadUpdates({String? lastSync, List<String>? dataTypes});
  Future<Map<String, dynamic>> uploadData(Map<String, dynamic> data);
  
  // Geofences
  Future<Map<String, dynamic>> checkGeofence(double lat, double lng, {String? pdvId});
  Future<void> enterGeofence(String pdvId, double lat, double lng);
  Future<void> exitGeofence(String pdvId, double lat, double lng);
}

class ApiDataSourceImpl implements ApiDataSource {
  late final Dio _dio;
  final String baseUrl;

  // Support local development with localhost API
  ApiDataSourceImpl({this.baseUrl = 'http://localhost/api/v1'}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add logging interceptor in debug mode
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    // Add error handling interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError) {
          throw Exception('Erreur de connexion - Vérifiez votre connexion internet');
        }
        
        if (error.response?.statusCode == 404) {
          throw Exception('Ressource non trouvée');
        }
        
        if (error.response?.statusCode == 500) {
          throw Exception('Erreur serveur - Veuillez réessayer plus tard');
        }

        final message = error.response?.data?['message'] ?? error.message;
        throw Exception(message);
      },
    ));
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password, String deviceName) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
        'device_name': deviceName,
      });
      return response.data;
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      throw Exception('Erreur de déconnexion: $e');
    }
  }

  @override
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  @override
  Future<Map<String, dynamic>> checkSync({String? lastSync}) async {
    try {
      final response = await _dio.get('/sync/check', queryParameters: {
        if (lastSync != null) 'last_sync': lastSync,
      });
      return response.data;
    } catch (e) {
      throw Exception('Erreur de vérification sync: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> downloadUpdates({String? lastSync, List<String>? dataTypes}) async {
    try {
      final response = await _dio.get('/sync/download', queryParameters: {
        if (lastSync != null) 'last_sync': lastSync,
        if (dataTypes != null) 'data_types': dataTypes,
      });
      return response.data;
    } catch (e) {
      throw Exception('Erreur de téléchargement sync: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> uploadData(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/sync/upload', data: {
        'data': data,
        'device_id': 'flutter-app',
        'sync_timestamp': DateTime.now().toIso8601String(),
      });
      return response.data;
    } catch (e) {
      throw Exception('Erreur d\'upload sync: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> checkGeofence(double lat, double lng, {String? pdvId}) async {
    try {
      final response = await _dio.post('/geofences/check', data: {
        'latitude': lat,
        'longitude': lng,
        if (pdvId != null) 'pdv_id': pdvId,
      });
      return response.data;
    } catch (e) {
      throw Exception('Erreur de vérification géofence: $e');
    }
  }

  @override
  Future<void> enterGeofence(String pdvId, double lat, double lng) async {
    try {
      await _dio.post('/geofences/enter', data: {
        'pdv_id': pdvId,
        'latitude': lat,
        'longitude': lng,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur entrée géofence: $e');
    }
  }

  @override
  Future<void> exitGeofence(String pdvId, double lat, double lng) async {
    try {
      await _dio.post('/geofences/exit', data: {
        'pdv_id': pdvId,
        'latitude': lat,
        'longitude': lng,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur sortie géofence: $e');
    }
  }

  @override
  Future<List<VisiteModel>> getVisites() async {
    try {
      final response = await _dio.get('/visites');
      final data = response.data['data']['visites'] as List;
      return data.map((json) => VisiteModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des visites: $e');
    }
  }

  @override
  Future<List<VisiteModel>> getVisitesByCommercial(String commercial) async {
    try {
      final response = await _dio.get(
        '/visites',
        queryParameters: {'commercial': commercial},
      );
      final data = response.data['data']['visites'] as List;
      return data.map((json) => VisiteModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des visites: $e');
    }
  }

  @override
  Future<VisiteModel> createVisite(VisiteModel visite) async {
    try {
      final response = await _dio.post(
        '/visites',
        data: visite.toJson(),
      );
      return VisiteModel.fromJson(response.data['data']['visite']);
    } catch (e) {
      throw Exception('Erreur lors de la création de la visite: $e');
    }
  }

  @override
  Future<VisiteModel> updateVisite(VisiteModel visite) async {
    try {
      final response = await _dio.put(
        '/visites/${visite.visiteId}',
        data: visite.toJson(),
      );
      return VisiteModel.fromJson(response.data['data']['visite']);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la visite: $e');
    }
  }

  @override
  Future<void> deleteVisite(String visiteId) async {
    try {
      await _dio.delete('/visites/$visiteId');
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la visite: $e');
    }
  }

  @override
  Future<List<PDVModel>> getPDVs() async {
    try {
      final response = await _dio.get('/pdvs');
      final data = response.data['data']['pdvs'] as List;
      return data.map((json) => PDVModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des PDV: $e');
    }
  }

  @override
  Future<List<PDVModel>> getPDVsBySecteur(String secteur) async {
    try {
      final response = await _dio.get(
        '/pdvs',
        queryParameters: {'secteur': secteur},
      );
      final data = response.data['data']['pdvs'] as List;
      return data.map((json) => PDVModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des PDV: $e');
    }
  }

  @override
  Future<List<PDVModel>> getNearbyPDVs(double lat, double lng, {double radius = 5000}) async {
    try {
      final response = await _dio.get(
        '/pdvs/nearby/$lat/$lng',
        queryParameters: {'radius': radius},
      );
      final data = response.data['data']['pdvs'] as List;
      return data.map((json) => PDVModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des PDV proches: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardAnalytics() async {
    try {
      final response = await _dio.get('/analytics/dashboard');
      return response.data['data'];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des analytics: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCommercialStats(String commercial) async {
    try {
      final response = await _dio.get('/analytics/commercial/$commercial');
      return response.data['data'];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des stats commercial: $e');
    }
  }

  // Upload image for visite
  Future<String> uploadVisiteImage(String visiteId, File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'visite_${visiteId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post(
        '/visites/$visiteId/image',
        data: formData,
      );

      return response.data['data']['url'];
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }
}