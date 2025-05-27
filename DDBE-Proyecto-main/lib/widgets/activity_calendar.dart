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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      padding: const EdgeInsets.all(16.0),
      child: TableCalendar(
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
          weekendTextStyle: TextStyle(color: widget.textColor.withOpacity(0.7)),
        ),
        headerStyle: HeaderStyle(
          titleTextStyle: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold),
          formatButtonVisible: false,
          leftChevronIcon: Icon(Icons.chevron_left, color: widget.textColor),
          rightChevronIcon: Icon(Icons.chevron_right, color: widget.textColor),
        ),
      ),
    );
  }
}