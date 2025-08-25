import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';
  static const String _routingKey = 'user_routing';

  // Utilisateurs de test selon le système créé
  static const Map<String, Map<String, dynamic>> _testUsers = {
    'test.treichville@friesland.ci': {
      'password': 'test123',
      'name': 'Merchandiser Test Treichville',
      'role': 'commercial',
      'zone': 'ABIDJAN SUD',
      'secteurs': ['TREICHVILLE', 'MARCORY'],
      'routing_id': 'route_carrossiers_001',
      'avatar': null,
    },
    'admin@friesland.local': {
      'password': 'admin123',
      'name': 'Administrator',
      'role': 'admin',
      'zone': 'TOUS',
      'secteurs': ['TOUS'],
      'routing_id': null,
      'avatar': null,
    },
    'commercial@friesland.local': {
      'password': 'commercial123',
      'name': 'Commercial Test',
      'role': 'commercial',
      'zone': 'ABIDJAN NORD',
      'secteurs': ['COCODY', 'PLATEAU'],
      'routing_id': 'route_cocody_001',
      'avatar': null,
    },
    'superviseur@friesland.local': {
      'password': 'superviseur123',
      'name': 'Superviseur Test',
      'role': 'supervisor',
      'zone': 'ABIDJAN',
      'secteurs': ['TREICHVILLE', 'COCODY', 'MARCORY'],
      'routing_id': 'route_supervision_001',
      'avatar': null,
    },
  };

  // État de l'utilisateur connecté
  Map<String, dynamic>? _currentUser;
  String? _currentToken;

  // Getters
  bool get isLoggedIn => _currentToken != null && _currentUser != null;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get currentToken => _currentToken;
  String? get userName => _currentUser?['name'];
  String? get userRole => _currentUser?['role'];
  String? get userZone => _currentUser?['zone'];
  List<String>? get userSecteurs => _currentUser?['secteurs']?.cast<String>();
  String? get userRoutingId => _currentUser?['routing_id'];

  /// Initialiser le service et vérifier si un utilisateur est déjà connecté
  Future<bool> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);

      if (token != null && userJson != null) {
        _currentToken = token;
        // Simuler la récupération des données utilisateur
        // En production, décoder depuis JSON ou faire un appel API
        final email = userJson;
        if (_testUsers.containsKey(email)) {
          _currentUser = Map.from(_testUsers[email]!);
          _currentUser!['email'] = email;
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erreur initialisation AuthService: $e');
      return false;
    }
  }

  /// Connexion utilisateur
  Future<bool> login(String email, String password) async {
    try {
      // Simuler délai réseau
      await Future.delayed(const Duration(milliseconds: 800));

      // Vérifier les credentials
      if (_testUsers.containsKey(email)) {
        final userData = _testUsers[email]!;
        if (userData['password'] == password) {
          // Succès de la connexion
          _currentToken = _generateToken(email);
          _currentUser = Map.from(userData);
          _currentUser!['email'] = email;

          // Sauvegarder en local
          await _saveAuthData(email);
          
          print('✅ Connexion réussie pour: ${_currentUser!['name']}');
          print('📍 Zone: ${_currentUser!['zone']}');
          print('🎯 Routing ID: ${_currentUser!['routing_id']}');
          
          return true;
        }
      }

      print('❌ Échec de connexion pour: $email');
      return false;
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_routingKey);

      _currentToken = null;
      _currentUser = null;

      print('✅ Déconnexion réussie');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }

  /// Vérifier si l'utilisateur a accès à une zone spécifique
  bool hasAccessToZone(String zone) {
    if (_currentUser == null) return false;
    
    final userZone = _currentUser!['zone'];
    final userSecteurs = _currentUser!['secteurs'] as List<String>?;
    
    // Admin a accès à tout
    if (userRole == 'admin' || userZone == 'TOUS') return true;
    
    // Vérifier la zone
    if (userZone == zone) return true;
    
    // Vérifier les secteurs
    if (userSecteurs != null && userSecteurs.contains(zone)) return true;
    
    return false;
  }

  /// Obtenir le routing par défaut de l'utilisateur
  String? getDefaultRouting() {
    return _currentUser?['routing_id'];
  }

  /// Générer un token simulé
  String _generateToken(String email) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'fr_token_${email.hashCode}_$timestamp';
  }

  /// Sauvegarder les données d'authentification
  Future<void> _saveAuthData(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _currentToken!);
    await prefs.setString(_userKey, email);
    
    // Sauvegarder le routing par défaut si disponible
    final routingId = _currentUser!['routing_id'];
    if (routingId != null) {
      await prefs.setString(_routingKey, routingId);
    }
  }

  /// Obtenir les statistiques utilisateur (pour l'interface)
  Map<String, dynamic> getUserStats() {
    if (_currentUser == null) {
      return {
        'total_visits': 0,
        'pending_sync': 0,
        'last_sync': null,
      };
    }

    // Simuler des statistiques basées sur le rôle
    switch (userRole) {
      case 'admin':
        return {
          'total_visits': 1250,
          'pending_sync': 3,
          'last_sync': DateTime.now().subtract(const Duration(minutes: 15)),
          'managed_zones': ['TOUS'],
        };
      case 'supervisor':
        return {
          'total_visits': 485,
          'pending_sync': 1,
          'last_sync': DateTime.now().subtract(const Duration(minutes: 8)),
          'managed_zones': userSecteurs,
        };
      case 'commercial':
        return {
          'total_visits': 87,
          'pending_sync': 2,
          'last_sync': DateTime.now().subtract(const Duration(minutes: 3)),
          'managed_zones': userSecteurs,
        };
      default:
        return {
          'total_visits': 0,
          'pending_sync': 0,
          'last_sync': null,
        };
    }
  }

  /// Vérifier si le token est encore valide (simulation)
  bool isTokenValid() {
    if (_currentToken == null) return false;
    
    // En production, vérifier l'expiration du token
    // Pour la démo, on considère que le token est toujours valide
    return true;
  }

  /// Rafraîchir le token (simulation)
  Future<bool> refreshToken() async {
    if (_currentUser == null) return false;
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final email = _currentUser!['email'];
      _currentToken = _generateToken(email);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _currentToken!);
      
      return true;
    } catch (e) {
      print('Erreur lors du rafraîchissement du token: $e');
      return false;
    }
  }
}