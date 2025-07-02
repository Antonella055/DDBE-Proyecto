// lib/widgets/student_list_widget.dart
import 'package:flutter/material.dart';

class StudentListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> students;

  const StudentListWidget({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        // Estos campos 'full_name' y 'email' son los que se aplanaron en SupabaseService
        final studentName =
            student['full_name']?.toString() ?? 'Nombre Desconocido';
        final studentEmail =
            student['email']?.toString() ?? 'Email Desconocido';
        final carnet =
            student['carnet']?.toString() ??
            'N/A'; // Campo 'carnet' de la tabla 'students'

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(studentName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Carnet: $carnet'),
                Text('Email: $studentEmail'),
                // Puedes añadir más detalles de la tabla 'students' aquí si los
                // necesitas, como carrera, trimestre, etc.
              ],
            ),
            onTap: () {
              // Acción al tocar un estudiante, por ejemplo, navegar a un detalle de estudiante
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tocaste a ${studentName}')),
              );
            },
          ),
        );
      },
    );
  }
}
