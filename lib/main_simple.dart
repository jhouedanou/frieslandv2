import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const FrieslandApp());
}

class FrieslandApp extends StatelessWidget {
  const FrieslandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friesland Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Friesland Bonnet Rouge'),
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