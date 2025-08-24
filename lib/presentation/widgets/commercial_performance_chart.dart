import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/themes/app_theme.dart';

class CommercialPerformanceChart extends StatelessWidget {
  const CommercialPerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Visites par commercial',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DropdownButton<String>(
                  value: 'Cette semaine',
                  items: const [
                    DropdownMenuItem(value: 'Aujourd\'hui', child: Text('Aujourd\'hui')),
                    DropdownMenuItem(value: 'Cette semaine', child: Text('Cette semaine')),
                    DropdownMenuItem(value: 'Ce mois', child: Text('Ce mois')),
                  ],
                  onChanged: (value) {
                    // Handle period change
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: _buildPieChartSections(),
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // Handle touch
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildCommercialsList(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final data = [
      {'name': 'COULIBALY PADIE', 'visits': 45, 'color': AppTheme.primaryColor},
      {'name': 'EBROTTIE MIAN', 'visits': 38, 'color': AppTheme.successColor},
      {'name': 'GAI KAMY', 'visits': 32, 'color': AppTheme.warningColor},
      {'name': 'OUATTARA ZANGA', 'visits': 28, 'color': Colors.blue},
      {'name': 'Guea Hermann', 'visits': 25, 'color': Colors.purple},
    ];

    final total = data.fold(0, (sum, item) => sum + (item['visits'] as int));

    return data.map((item) {
      final visits = item['visits'] as int;
      final percentage = (visits / total * 100);
      
      return PieChartSectionData(
        color: item['color'] as Color,
        value: visits.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildCommercialsList() {
    final commercials = [
      {'name': 'COULIBALY PADIE', 'visits': 45, 'target': 50, 'color': AppTheme.primaryColor},
      {'name': 'EBROTTIE MIAN CHRISTIAN', 'visits': 38, 'target': 45, 'color': AppTheme.successColor},
      {'name': 'GAI KAMY', 'visits': 32, 'target': 40, 'color': AppTheme.warningColor},
      {'name': 'OUATTARA ZANGA', 'visits': 28, 'target': 35, 'color': Colors.blue},
      {'name': 'Guea Hermann', 'visits': 25, 'target': 30, 'color': Colors.purple},
    ];

    return Column(
      children: commercials.map((commercial) {
        final visits = commercial['visits'] as int;
        final target = commercial['target'] as int;
        final progress = visits / target;
        final color = commercial['color'] as Color;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Text(
                  commercial['name'] as String,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$visits/$target',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}