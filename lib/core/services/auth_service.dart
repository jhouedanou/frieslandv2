import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/api_datasource.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  late final ApiDataSource _apiDataSource;
  
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>?> _userController = StreamController<Map<String, dynamic>?>.broadcast();
  
  Stream<bool> get authStateStream => _authStateController.stream;
  Stream<Map<String, dynamic>?> get userStream => _userController.stream;
  
  bool _isAuthenticated = false;
  Map<String, dynamic>? _currentUser;
  String? _token;
  
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get token => _token;

  Future<void> initialize(ApiDataSource apiDataSource) async {
    _apiDataSource = apiDataSource;
    await _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    
    _token = prefs.getString('auth_token');
    final userJson = prefs.getString('current_user');
    
    if (_token != null && userJson != null) {
      _currentUser = jsonDecode(userJson);
      _isAuthenticated = true;
      _apiDataSource.setAuthToken(_token!);
      
      // Notify listeners
      _authStateController.add(true);
      _userController.add(_currentUser);
      
      // Optionally verify token validity
      await _verifyToken();
    }
  }

  Future<void> _verifyToken() async {
    try {
      // Try to make an authenticated request to verify token is still valid
      await _apiDataSource.getDashboardAnalytics();
    } catch (e) {
      // Token is invalid, logout
      await logout();
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiDataSource.login(email, password, 'Flutter App');
      
      _token = response['token'] as String;
      _currentUser = response['user'] as Map<String, dynamic>;
      _isAuthenticated = true;
      
      // Set token for API requests
      _apiDataSource.setAuthToken(_token!);
      
      // Store auth data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('current_user', jsonEncode(_currentUser!));
      
      // Notify listeners
      _authStateController.add(true);
      _userController.add(_currentUser);
      
      return response;
    } catch (e) {
      throw Exception('Échec de connexion: $e');
    }
  }

  Future<void> logout() async {
    try {
      if (_isAuthenticated) {
        await _apiDataSource.logout();
      }
    } catch (e) {
      // Ignore logout errors, we'll clear local state anyway
      print('Erreur de déconnexion: $e');
    } finally {
      // Clear local state
      _token = null;
      _currentUser = null;
      _isAuthenticated = false;
      
      // Clear stored auth data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('current_user');
      
      // Notify listeners
      _authStateController.add(false);
      _userController.add(null);
    }
  }

  Future<void> refreshToken() async {
    if (!_isAuthenticated || _token == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      // For now, we'll just verify the existing token
      // In a production app, you'd implement token refresh
      await _verifyToken();
    } catch (e) {
      throw Exception('Impossible de rafraîchir le token: $e');
    }
  }

  bool hasRole(String role) {
    if (_currentUser == null) return false;
    
    final userRole = _currentUser!['role'] as String?;
    return userRole == role || userRole == 'admin';
  }

  bool hasPermission(String permission) {
    if (_currentUser == null) return false;
    
    // Simple permission checking - extend as needed
    final roles = _currentUser!['roles'] as List?;
    if (roles == null) return false;
    
    return roles.any((role) => 
      (role['permissions'] as List?)?.contains(permission) == true
    );
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    if (!_isAuthenticated) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      // Update user profile via API
      // This would need to be implemented in the API datasource
      // await _apiDataSource.updateProfile(profileData);
      
      // Update local user data
      _currentUser = {..._currentUser!, ...profileData};
      
      // Store updated user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(_currentUser!));
      
      // Notify listeners
      _userController.add(_currentUser);
    } catch (e) {
      throw Exception('Échec de mise à jour du profil: $e');
    }
  }

  void dispose() {
    _authStateController.close();
    _userController.close();
  }
}