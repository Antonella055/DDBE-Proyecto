import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraficoHorasEstudiantes extends StatelessWidget {
  final Map<String, int> horasPorEstudiante;

  const GraficoHorasEstudiantes({super.key, required this.horasPorEstudiante});

  @override
  Widget build(BuildContext context) {
    if (horasPorEstudiante.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final estudiantes = horasPorEstudiante.keys.toList();
    final horas = horasPorEstudiante.values.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            horas.isNotEmpty
                ? horas.reduce((a, b) => a > b ? a : b).toDouble() + 2
                : 10,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= estudiantes.length)
                  return const SizedBox();
                return RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    estudiantes[idx],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        barGroups: List.generate(estudiantes.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: horas[i].toDouble(),
                color: Colors.blue,
                width: 18,
              ),
            ],
          );
        }),
      ),
    );
  }
}
