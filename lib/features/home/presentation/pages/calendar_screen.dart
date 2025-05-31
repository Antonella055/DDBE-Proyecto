import 'package:flutter/material.dart';
import '../widgets/activity_calendar.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario de Actividades')),
      body: ActivityCalendar(
        textColor: Colors.black,
        backgroundColor: Colors.white,
      ),
    );
  }
}

