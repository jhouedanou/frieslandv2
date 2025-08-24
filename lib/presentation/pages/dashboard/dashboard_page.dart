import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/product_presence_chart.dart';
import '../../widgets/commercial_performance_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Friesland'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Export data
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Overview
            Text(
              'Vue d\'ensemble',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            
            // KPI Cards Row 1
            const Row(
              children: [
                Expanded(
                  child: KPICard(
                    title: 'Total Visites',
                    value: '1,234',
                    subtitle: '+12% ce mois',
                    color: AppTheme.primaryColor,
                    icon: Icons.store,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: KPICard(
                    title: 'PDV Actifs',
                    value: '856',
                    subtitle: '94% couverture',
                    color: AppTheme.successColor,
                    icon: Icons.location_on,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // KPI Cards Row 2
            const Row(
              children: [
                Expanded(
                  child: KPICard(
                    title: 'Prix Respectés',
                    value: '78%',
                    subtitle: 'Moyenne générale',
                    color: AppTheme.warningColor,
                    icon: Icons.attach_money,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: KPICard(
                    title: 'Alertes',
                    value: '23',
                    subtitle: 'Nécessitent attention',
                    color: AppTheme.errorColor,
                    icon: Icons.warning,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Product Presence Chart
            Text(
              'Présence Produits par Catégorie',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const ProductPresenceChart(),
            
            const SizedBox(height: 32),
            
            // Commercial Performance
            Text(
              'Performance par Commercial',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const CommercialPerformanceChart(),
            
            const SizedBox(height: 32),
            
            // Recent Alerts
            Text(
              'Alertes Récentes',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _buildAlertsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/visit-form');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Card(
      child: Column(
        children: [
          _buildAlertItem(
            'Rupture EVAP BR Gold',
            'Boutique Central - Abidjan',
            Icons.error,
            AppTheme.errorColor,
          ),
          const Divider(height: 1),
          _buildAlertItem(
            'Prix non respecté IMP BR 400g',
            'Superette Nord - Yamoussoukro',
            Icons.warning,
            AppTheme.warningColor,
          ),
          const Divider(height: 1),
          _buildAlertItem(
            'Nouvelle visite requise',
            'Kiosque Est - Bouaké',
            Icons.info,
            AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String subtitle, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        'Il y a 2h',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () {
        // Handle alert tap
      },
    );
  }
}