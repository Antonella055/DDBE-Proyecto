import 'package:flutter/material.dart';
import 'package:ayudantia_software/services/supabase_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _horas = [];

  Future<void> registrarHoras(DateTime fecha, int horas) async {
    await _supabaseService.registrarHorasCulminadas(fecha, horas);
    await cargarHoras(); // Recarga después de registrar
  }

  Future<void> cargarHoras() async {
    final horas = await _supabaseService.obtenerHorasUsuarioActual();
    setState(() {
      _horas = horas;
    });
  }

  @override
  void initState() {
    super.initState();
    cargarHoras();
  }

  @override
  Widget build(BuildContext context) {
    int totalHoras = _horas.fold(
      0,
      (sum, item) => sum + (item['horas'] as int),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue,
          child: Text(
            '$totalHoras',
            style: const TextStyle(fontSize: 32, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
