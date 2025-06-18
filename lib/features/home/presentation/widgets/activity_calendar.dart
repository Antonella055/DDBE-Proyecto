import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ayudantia_software/services/supabase_service.dart';

class ActivityCalendar extends StatefulWidget {
  final Color textColor;
  final Color backgroundColor;

  const ActivityCalendar({
    super.key,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  State<ActivityCalendar> createState() => _ActivityCalendarState();
}

class _ActivityCalendarState extends State<ActivityCalendar> {
  final SupabaseService _supabaseService = SupabaseService();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _activities = {};

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final data = await _supabaseService.getCalendario();
    setState(() {
      _activities.clear();
      for (var item in data) {
        final date = DateTime.parse(item['dia']);
        final key = DateTime(date.year, date.month, date.day);
        _activities.putIfAbsent(key, () => []);
        _activities[key]!.add({
          'id': item['id'],
          'evento': item['evento'],
          'descripcion': item['descripcion'],
          'lugar': item['lugar'],
          'hora': item['hora'],
        });
      }
    });
  }

  String formatHora(dynamic hora) {
    if (hora == null) return '';
    return hora.toString().substring(0, 5); // HH:mm
  }

  Future<void> _showEditDialog(Map<String, dynamic> activity) async {
    final eventoController = TextEditingController(
      text: activity['evento'] ?? '',
    );
    final descripcionController = TextEditingController(
      text: activity['descripcion'] ?? '',
    );
    final lugarController = TextEditingController(
      text: activity['lugar'] ?? '',
    );
    final horaController = TextEditingController(
      text: activity['hora'] != null ? formatHora(activity['hora']) : '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Editar actividad'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: eventoController,
                          decoration: const InputDecoration(hintText: 'Evento'),
                        ),
                        TextField(
                          controller: descripcionController,
                          decoration: const InputDecoration(
                            hintText: 'Descripción',
                          ),
                        ),
                        TextField(
                          controller: lugarController,
                          decoration: const InputDecoration(hintText: 'Lugar'),
                        ),
                        TextField(
                          controller: horaController,
                          decoration: const InputDecoration(
                            hintText: 'Hora (HH:mm)',
                          ),
                          keyboardType: TextInputType.datetime,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
          ),
    );

    if (result == true &&
        eventoController.text.trim().isNotEmpty &&
        descripcionController.text.trim().isNotEmpty &&
        lugarController.text.trim().isNotEmpty &&
        horaController.text.trim().isNotEmpty) {
      final horaTexto = horaController.text.trim();
      final horaRegExp = RegExp(r'^\d{2}:\d{2}$');
      if (!horaRegExp.hasMatch(horaTexto)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La hora debe estar en formato HH:mm')),
        );
        return;
      }
      final horaParts = horaTexto.split(':');
      final horaString =
          '${horaParts[0].padLeft(2, '0')}:${horaParts[1].padLeft(2, '0')}:00';
      await _supabaseService.updateActivity(
        id: activity['id'],
        evento: eventoController.text.trim(),
        descripcion: descripcionController.text.trim(),
        lugar: lugarController.text.trim(),
        hora: horaString,
      );
      await _loadActivities();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Actividad actualizada')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: widget.backgroundColor,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader:
                    (day) =>
                        _activities[DateTime(day.year, day.month, day.day)] ??
                        [],
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: widget.textColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: widget.textColor,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: widget.textColor),
                  weekendTextStyle: TextStyle(
                    color: widget.textColor.withOpacity(0.7),
                  ),
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  formatButtonVisible: false,
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: widget.textColor,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: widget.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedDay != null)
                ...(_activities[DateTime(
                          _selectedDay!.year,
                          _selectedDay!.month,
                          _selectedDay!.day,
                        )] ??
                        [])
                    .map(
                      (activity) => ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(activity['evento'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (activity['descripcion'] != null)
                              Text('Descripción: ${activity['descripcion']}'),
                            if (activity['lugar'] != null)
                              Text('Lugar: ${activity['lugar']}'),
                            if (activity['hora'] != null)
                              Text('Hora: ${formatHora(activity['hora'])}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await _showEditDialog(activity);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _supabaseService.deleteActivity(
                                  activity['id'],
                                );
                                await _loadActivities();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Evento eliminado'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: widget.textColor,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              if (_selectedDay == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Selecciona un día en el calendario'),
                  ),
                );
                return;
              }
              final eventoController = TextEditingController();
              final descripcionController = TextEditingController();
              final lugarController = TextEditingController();
              final horaController = TextEditingController();

              final result = await showDialog<bool>(
                context: context,
                builder:
                    (context) => StatefulBuilder(
                      builder:
                          (context, setState) => AlertDialog(
                            title: const Text('Agregar actividad'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: eventoController,
                                    decoration: const InputDecoration(
                                      hintText: 'Evento',
                                    ),
                                  ),
                                  TextField(
                                    controller: descripcionController,
                                    decoration: const InputDecoration(
                                      hintText: 'Descripción',
                                    ),
                                  ),
                                  TextField(
                                    controller: lugarController,
                                    decoration: const InputDecoration(
                                      hintText: 'Lugar',
                                    ),
                                  ),
                                  TextField(
                                    controller: horaController,
                                    decoration: const InputDecoration(
                                      hintText: 'Hora (HH:mm)',
                                    ),
                                    keyboardType: TextInputType.datetime,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Guardar'),
                              ),
                            ],
                          ),
                    ),
              );

              if (result == true &&
                  eventoController.text.trim().isNotEmpty &&
                  descripcionController.text.trim().isNotEmpty &&
                  lugarController.text.trim().isNotEmpty &&
                  horaController.text.trim().isNotEmpty) {
                final horaTexto = horaController.text.trim();
                final horaRegExp = RegExp(r'^\d{2}:\d{2}$');
                if (!horaRegExp.hasMatch(horaTexto)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La hora debe estar en formato HH:mm'),
                    ),
                  );
                  return;
                }
                final horaParts = horaTexto.split(':');
                final horaString =
                    '${horaParts[0].padLeft(2, '0')}:${horaParts[1].padLeft(2, '0')}:00';
                await _supabaseService.addActivity(
                  dia: _selectedDay!,
                  evento: eventoController.text.trim(),
                  descripcion: descripcionController.text.trim(),
                  lugar: lugarController.text.trim(),
                  hora: horaString,
                );
                await _loadActivities();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Actividad guardada en Supabase'),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
