import 'package:flutter/material.dart';
import '../widgets/filtro.dart';
import '../widgets/estadisticas_del_estudiante.dart';
import 'package:ayudantia_software/services/supabase_service.dart';

class DashboardProfesor extends StatefulWidget {
  final String profesorId;
  const DashboardProfesor({super.key, required this.profesorId});

  @override
  State<DashboardProfesor> createState() => _DashboardProfesorState();
}

class _DashboardProfesorState extends State<DashboardProfesor> {
  String? actividadSeleccionada;
  int? mesSeleccionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel del Profesor')),
      body: Column(
        children: [
          // Filtro
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FiltroWidget(
              actividades: const ['Actividad 1', 'Actividad 2', 'Actividad 3'],
              onFiltrar: (actividad, mes) {
                setState(() {
                  actividadSeleccionada = actividad;
                  mesSeleccionado = mes;
                });
              },
            ),
          ),
          // Estadísticas y lista de horas
          Expanded(
            child: HorasEstudiantesYEstadisticas(
              profesorId: widget.profesorId,
              actividad: actividadSeleccionada,
              mes: mesSeleccionado,
            ),
          ),
        ],
      ),
    );
  }
}

class HorasEstudiantesYEstadisticas extends StatefulWidget {
  final String profesorId;
  final String? actividad;
  final int? mes;

  const HorasEstudiantesYEstadisticas({
    super.key,
    required this.profesorId,
    this.actividad,
    this.mes,
  });

  @override
  State<HorasEstudiantesYEstadisticas> createState() =>
      _HorasEstudiantesYEstadisticasState();
}

class _HorasEstudiantesYEstadisticasState
    extends State<HorasEstudiantesYEstadisticas> {
  List<Map<String, dynamic>> _horas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    cargarHoras();
  }

  @override
  void didUpdateWidget(covariant HorasEstudiantesYEstadisticas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actividad != widget.actividad ||
        oldWidget.mes != widget.mes) {
      cargarHoras();
    }
  }

  Future<void> cargarHoras() async {
    setState(() => _loading = true);
    final supabaseService = SupabaseService();
    final horas = await supabaseService.obtenerHorasDeEstudiantesDelProfesor(
      widget.profesorId,
      mes: widget.mes,
    );
    setState(() {
      _horas = horas;
      _loading = false;
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

    Map<String, int> horasPorEstudiante = {};
    for (final item in _horas) {
      final nombre = item['estudiantes']?['nombre'] ?? 'Sin nombre';
      final horas =
          item['horas'] is int
              ? item['horas'] as int
              : int.tryParse(item['horas']?.toString() ?? '0') ?? 0;
      horasPorEstudiante[nombre] = (horasPorEstudiante[nombre] ?? 0) + horas;
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total horas: $totalHoras',
            style: const TextStyle(fontSize: 24),
          ),
        ),
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
    );
  }
}
