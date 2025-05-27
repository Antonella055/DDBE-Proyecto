import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mapa para guardar actividades por fecha
  Map<DateTime, List<String>> _activities = {};

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
                eventLoader:
                    (day) =>
                        _activities[DateTime(day.year, day.month, day.day)] ??
                        [],
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
                        title: Text(activity),
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
              if (_selectedDay == null) return;
              final controller = TextEditingController();
              final result = await showDialog<String>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Agregar actividad'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Descripción de la actividad',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed:
                              () => Navigator.pop(context, controller.text),
                          child: const Text('Agregar'),
                        ),
                      ],
                    ),
              );
              if (result != null && result.trim().isNotEmpty) {
                setState(() {
                  final dayKey = DateTime(
                    _selectedDay!.year,
                    _selectedDay!.month,
                    _selectedDay!.day,
                  );
                  _activities.putIfAbsent(dayKey, () => []);
                  _activities[dayKey]!.add(result.trim());
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
