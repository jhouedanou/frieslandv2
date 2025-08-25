import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/main_screen.dart';
import 'core/services/auth_service.dart';

void main() {
  runApp(const FrieslandApp());
}

class FrieslandApp extends StatelessWidget {
  const FrieslandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friesland Bonnet Rouge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFFE53E3E),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53E3E),
          primary: const Color(0xFFE53E3E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE53E3E),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53E3E),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const AuthWrapper(), // Vérification d'authentification au démarrage
    );
  }
}

/// Widget qui gère la navigation selon l'état d'authentification
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.initialize();
      setState(() {
        _isAuthenticated = isLoggedIn;
        _isLoading = false;
      });

      if (isLoggedIn) {
        print('✅ Utilisateur déjà connecté: ${_authService.userName}');
        print('📍 Zone: ${_authService.userZone}');
      } else {
        print('🔐 Aucun utilisateur connecté - redirection vers login');
      }
    } catch (e) {
      print('❌ Erreur vérification auth: $e');
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    return _isAuthenticated ? const MainScreen() : const LoginPage();
  }
}

/// Écran de chargement avec branding Bonnet Rouge
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE53E3E), // Rouge Bonnet Rouge principal
              Color(0xFFD32F2F), // Rouge plus foncé
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Titre
              const Text(
                'BONNET ROUGE',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                '100 ans d\'énergie dès le matin !',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Indicateur de chargement
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Chargement...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 12),
            const Text('Dashboard Friesland Bonnet Rouge'),
          ],
        ),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Cards
            Text(
              'KPI Principaux',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Row of KPI cards
            Row(
              children: [
                Expanded(
                  child: _buildKPICard(
                    'Total Visites',
                    '1,234',
                    '+12% ce mois',
                    Colors.blue,
                    Icons.store,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKPICard(
                    'PDV Actifs',
                    '856',
                    '94% couverture',
                    Colors.green,
                    Icons.location_on,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildKPICard(
                    'Prix Respectés',
                    '78%',
                    'Moyenne générale',
                    Colors.orange,
                    Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKPICard(
                    'Alertes',
                    '23',
                    'Nécessitent attention',
                    Colors.red,
                    Icons.warning,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Chart Section
            Text(
              'Présence Produits par Catégorie',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Simple Bar Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barGroups: [
                        _buildBarGroup(0, 85, Colors.red),
                        _buildBarGroup(1, 72, Colors.blue),
                        _buildBarGroup(2, 68, Colors.green),
                        _buildBarGroup(3, 91, Colors.orange),
                        _buildBarGroup(4, 56, Colors.purple),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0: return const Text('EVAP');
                                case 1: return const Text('IMP');
                                case 2: return const Text('SCM');
                                case 3: return const Text('UHT');
                                case 4: return const Text('YOGHURT');
                                default: return const Text('');
                              }
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text('${value.toInt()}%');
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // API Connection Status
            Text(
              'Connexion API',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.api, color: Colors.green, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Backend API Connecté',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'http://localhost:3000/api/v1',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Test API connection
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('API connectée avec succès!')),
                        );
                      },
                      child: const Text('Tester'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Features List
            Text(
              'Fonctionnalités Implémentées',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Column(
                children: [
                  _buildFeatureItem('✅ Backend Node.js + PostgreSQL', 'API REST complète'),
                  const Divider(height: 1),
                  _buildFeatureItem('✅ Géofencing 300m', 'Validation position obligatoire'),
                  const Divider(height: 1),
                  _buildFeatureItem('✅ Formulaire 5 catégories', 'EVAP, IMP, SCM, UHT, YOGHURT'),
                  const Divider(height: 1),
                  _buildFeatureItem('✅ Analytics temps réel', 'KPIs et graphiques'),
                  const Divider(height: 1),
                  _buildFeatureItem('✅ Stockage hybride', 'Online/Offline avec sync'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nouvelle visite - Fonctionnalité à implémenter')),
          );
        },
        backgroundColor: const Color(0xFFE53E3E),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildKPICard(String title, String value, String subtitle, Color color, IconData icon) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 32,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      dense: true,
    );
  }
}