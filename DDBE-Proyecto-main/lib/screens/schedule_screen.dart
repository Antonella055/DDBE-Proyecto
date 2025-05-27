import 'package:flutter/material.dart';
import 'package:ayudantia_software/widgets/activity_calendar.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario de Actividades')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ActivityCalendar(
          textColor: Colors.black,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
