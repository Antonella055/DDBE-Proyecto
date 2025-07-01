// lib/screens/professor_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:ayudantia_software/services/supabase_service.dart';
import '../widgets/student_list_widget.dart';

class ProfessorDashboardScreen extends StatefulWidget {
  final String professorId; // El ID del profesor actual

  const ProfessorDashboardScreen({super.key, required this.professorId});

  @override
  State<ProfessorDashboardScreen> createState() =>
      _ProfessorDashboardScreenState();
}

class _ProfessorDashboardScreenState extends State<ProfessorDashboardScreen> {
  late Future<List<Map<String, dynamic>>> _studentsFuture;
  late final String id_supervisor;

  @override
  void initState() {
    super.initState();
    // Cuando el widget se inicializa, carga los estudiantes del profesor
    _studentsFuture = SupabaseService().getStudentsByProfessorId(
      widget.professorId,
    );
  }

  // Puedes añadir una función para refrescar la lista si es necesario
  Future<void> _refreshStudents() async {
    // Función para recargar los estudiantes, útil para RefreshIndicator
    setState(() {
      _studentsFuture = SupabaseService().getStudentsByProfessorId(
        widget.professorId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard del Profesor')),
      body: RefreshIndicator(
        onRefresh: _refreshStudents,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _studentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Si hay un error al cargar los datos
              return Center(
                child: Text('Error al cargar estudiantes: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Si no hay datos (la lista está vacía)
              return const Center(
                child: Text('No tienes estudiantes asignados.'),
              );
            } else {
              // Si los datos se cargaron correctamente, muestra la lista de estudiantes
              return StudentListWidget(students: snapshot.data!);
            }
          },
        ),
      ),
    );
  }
}
