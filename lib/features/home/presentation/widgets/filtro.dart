import 'package:flutter/material.dart';

class FiltroWidget extends StatefulWidget {
  final List<String> actividades;
  final Function(String? actividad, int? mes) onFiltrar;

  const FiltroWidget({
    super.key,
    required this.actividades,
    required this.onFiltrar,
  });

  @override
  State<FiltroWidget> createState() => _FiltroWidgetState();
}

class _FiltroWidgetState extends State<FiltroWidget> {
  String? actividadSeleccionada;
  int? mesSeleccionado;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownButton<String>(
          hint: const Text('Actividad'),
          value: actividadSeleccionada,
          items:
              widget.actividades
                  .map((act) => DropdownMenuItem(value: act, child: Text(act)))
                  .toList(),
          onChanged: (value) {
            setState(() {
              actividadSeleccionada = value;
            });
            widget.onFiltrar(actividadSeleccionada, mesSeleccionado);
          },
        ),
        const SizedBox(width: 16),
        DropdownButton<int>(
          hint: const Text('Mes'),
          value: mesSeleccionado,
          items: List.generate(
            12,
            (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
          ),
          onChanged: (value) {
            setState(() {
              mesSeleccionado = value;
            });
            widget.onFiltrar(actividadSeleccionada, mesSeleccionado);
          },
        ),
      ],
    );
  }
}
