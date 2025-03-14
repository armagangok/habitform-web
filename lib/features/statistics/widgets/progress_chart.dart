import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Chart types supported
enum ChartType {
  bar,
  line,
}

/// Widget for displaying progress data in different chart formats
class ProgressChart extends StatelessWidget {
  final Map<String, double> data;
  final ChartType chartType;

  const ProgressChart({
    super.key,
    required this.data,
    required this.chartType,
  });

  @override
  Widget build(BuildContext context) {
    return chartType == ChartType.bar ? _buildBarChart(context) : _buildLineChart(context);
  }

  Widget _buildBarChart(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.keys.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    data.keys.elementAt(value.toInt()),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 0.2 != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '${(value * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _getBarGroups(),
        maxY: 1,
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          horizontalInterval: 0.2,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Display every 5th day for monthly chart
                final showEvery = data.length > 15 ? 5 : 1;
                final index = value.toInt();

                if (index >= data.length || index % showEvery != 0) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    data.keys.elementAt(index),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 0.2 != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '${(value * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _getLineSpots(),
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: Theme.of(context).primaryColor,
                strokeWidth: 2,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
            ),
          ),
        ],
        maxY: 1,
        minY: 0,
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    final List<BarChartGroupData> barGroups = [];

    int index = 0;
    for (final entry in data.entries) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              color: Colors.blue,
              width: 15,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
      index++;
    }

    return barGroups;
  }

  List<FlSpot> _getLineSpots() {
    final List<FlSpot> spots = [];

    int index = 0;
    for (final entry in data.entries) {
      spots.add(FlSpot(index.toDouble(), entry.value));
      index++;
    }

    return spots;
  }
}
