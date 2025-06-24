import 'package:flutter/material.dart';
import 'package:ayudantia_software/services/supabase_service.dart';
import 'filtro.dart';
import 'estadisticas_del_estudiante.dart'; // Importa el gráfico

class EstadisticasProfe extends StatefulWidget {
  final String profesorId; // Pasa el id del profesor

  const EstadisticasProfe({super.key, required this.profesorId});

  @override
  State<EstadisticasProfe> createState() => _EstadisticasProfeState();
}

class _EstadisticasProfeState extends State<EstadisticasProfe> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _horas = [];
  List<String> actividades = [
    'Actividad 1',
    'Actividad 2',
    'Actividad 3',
  ]; // Puedes cargar esto dinámicamente si lo necesitas

  String? actividadSeleccionada;
  int? mesSeleccionado;

  @override
  void initState() {
    super.initState();
    cargarHoras();
  }

  Future<void> cargarHoras({String? actividad, int? mes}) async {
    final horas = await _supabaseService.obtenerHorasDeEstudiantesDelProfesor(
      widget.profesorId,

      mes: mes,
    );
    setState(() {
      _horas = horas;
      actividadSeleccionada = actividad;
      mesSeleccionado = mes;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalHoras = _horas.fold(
      0,
      (sum, item) =>
          sum +
          (item['horas'] is int
              ? item['horas'] as int
              : int.tryParse(item['horas']?.toString() ?? '0') ?? 0),
    );

    // Calcula el mapa de horas por estudiante para el gráfico
    Map<String, int> horasPorEstudiante = {};
    for (final item in _horas) {
      final nombre = item['estudiantes']?['nombre'] ?? 'Sin nombre';
      final horas =
          item['horas'] is int
              ? item['horas'] as int
              : int.tryParse(item['horas']?.toString() ?? '0') ?? 0;
      horasPorEstudiante[nombre] = (horasPorEstudiante[nombre] ?? 0) + horas;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Horas de mis estudiantes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FiltroWidget(
              actividades: actividades,
              onFiltrar: (actividad, mes) {
                cargarHoras(actividad: actividad, mes: mes);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total horas: $totalHoras',
              style: const TextStyle(fontSize: 24),
            ),
          ),
          // Aquí va el gráfico
          if (horasPorEstudiante.isNotEmpty)
            SizedBox(
              height: 250,
              child: GraficoHorasEstudiantes(
                horasPorEstudiante: horasPorEstudiante,
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                ..._horas.map(
                  (item) => ListTile(
                    title: Text(
                      'Estudiante: ${item['estudiantes'] != null ? item['estudiantes']['nombre'] ?? '' : ''}',
                    ),
                    subtitle: Text('Fecha: ${item['fecha']}'),
                    trailing: Text('Horas: ${item['horas']}'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
