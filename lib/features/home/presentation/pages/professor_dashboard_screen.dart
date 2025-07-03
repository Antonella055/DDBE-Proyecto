// lib/screens/professor_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:ayudantia_software/services/supabase_service.dart';
import '../widgets/student_list_widget.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_footer.dart';

class ProfessorDashboardScreen extends StatefulWidget {
  final String professorId; // El ID del profesor actual

  const ProfessorDashboardScreen({super.key, required this.professorId});

  @override
  State<ProfessorDashboardScreen> createState() =>
      _ProfessorDashboardScreenState();
}

class _ProfessorDashboardScreenState extends State<ProfessorDashboardScreen> {
  late Future<List<Map<String, dynamic>>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = SupabaseService().getStudentsByProfessorId(
      widget.professorId,
    );
  }

  Future<void> _refreshStudents() async {
    setState(() {
      _studentsFuture = SupabaseService().getStudentsByProfessorId(
        widget.professorId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        scaffoldKey: GlobalKey<ScaffoldState>(),
        currentRoute: '/dashboard',
        onProfileIconPressed: () {
          // Acción para el icono de perfil si lo necesitas
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshStudents,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _studentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error al cargar estudiantes: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No tienes estudiantes asignados.'),
                    );
                  } else {
                    return StudentListWidget(students: snapshot.data!);
                  }
                },
              ),
            ),
          ),
          CustomFooter(
            textColor: Colors.black,
            backgroundColor: Colors.grey[200]!,
          ),
        ],
      ),
    );
  }
}
