import 'package:flutter/material.dart';

class FiltroWidget extends StatelessWidget {
  final List<String> actividades;
  final String? actividadSeleccionada;
  final int? mesSeleccionado;
  final void Function(String?, int?) onFiltrar;

  const FiltroWidget({
    super.key,
    required this.actividades,
    required this.actividadSeleccionada,
    required this.mesSeleccionado,
    required this.onFiltrar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Filtro de actividad
          Expanded(
            child: DropdownButton<String>(
              value: actividadSeleccionada,
              hint: const Text('Selecciona actividad'),
              isExpanded: true,
              items: actividades.map((actividad) {
                return DropdownMenuItem<String>(
                  value: actividad,
                  child: Text(actividad),
                );
              }).toList(),
              onChanged: (value) {
                onFiltrar(value, mesSeleccionado);
              },
            ),
          ),
          const SizedBox(width: 8),
          // Filtro de mes
          Expanded(
            child: DropdownButton<int>(
              value: mesSeleccionado,
              hint: const Text('Mes'),
              isExpanded: true,
              items: List.generate(12, (i) => i + 1).map((mes) {
                return DropdownMenuItem<int>(
                  value: mes,
                  child: Text('Mes $mes'),
                );
              }).toList(),
              onChanged: (value) {
                onFiltrar(actividadSeleccionada, value);
              },
            ),
          ),
        ],
      ),
    );
  }
}