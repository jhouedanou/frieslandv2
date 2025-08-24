import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/themes/app_theme.dart';

class ProductPresenceChart extends StatelessWidget {
  const ProductPresenceChart({super.key});

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
                  'Taux de présence par catégorie',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    // Handle menu selection
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'export', child: Text('Exporter')),
                    const PopupMenuItem(value: 'details', child: Text('Détails')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('EVAP', style: TextStyle(fontSize: 12));
                            case 1:
                              return const Text('IMP', style: TextStyle(fontSize: 12));
                            case 2:
                              return const Text('SCM', style: TextStyle(fontSize: 12));
                            case 3:
                              return const Text('UHT', style: TextStyle(fontSize: 12));
                            case 4:
                              return const Text('YOGHURT', style: TextStyle(fontSize: 12));
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _buildBarGroup(0, 85, AppTheme.primaryColor),
                    _buildBarGroup(1, 72, AppTheme.successColor),
                    _buildBarGroup(2, 68, AppTheme.warningColor),
                    _buildBarGroup(3, 91, Colors.blue),
                    _buildBarGroup(4, 56, Colors.purple),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
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

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('EVAP', AppTheme.primaryColor, '85%'),
        _buildLegendItem('IMP', AppTheme.successColor, '72%'),
        _buildLegendItem('SCM', AppTheme.warningColor, '68%'),
        _buildLegendItem('UHT', Colors.blue, '91%'),
        _buildLegendItem('YOGHURT', Colors.purple, '56%'),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String percentage) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ($percentage)',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}