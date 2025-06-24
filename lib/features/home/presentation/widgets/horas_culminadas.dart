import 'package:flutter/material.dart';
import 'package:ayudantia_software/services/supabase_service.dart';

class HorasCulminadasWidget extends StatefulWidget {
  final String idEstudiante;

  const HorasCulminadasWidget({super.key, required this.idEstudiante});

  @override
  State<HorasCulminadasWidget> createState() => _HorasCulminadasWidgetState();
}

class _HorasCulminadasWidgetState extends State<HorasCulminadasWidget> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _horas = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    cargarHoras();
  }

  Future<void> cargarHoras() async {
    setState(() => _loading = true);
    try {
      final horas = await _supabaseService.obtenerHorasPorIdEstudiante(
        widget.idEstudiante,
      );
      setState(() {
        _horas = horas;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar horas: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> registrarHoras(
    DateTime fecha,
    int horas,
    String descripcion,
  ) async {
    try {
      await _supabaseService.registrarHoras(
        idEstudiante: widget.idEstudiante, // ✅
        fecha: fecha,
        horas: horas,
        descripcion: descripcion,
        //
      );
      await cargarHoras();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Horas registradas')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalHoras =
        _horas
            .fold<num>(
              0,
              (sum, item) =>
                  sum +
                  (item['horas'] is int
                      ? item['horas']
                      : int.tryParse(item['horas'].toString()) ?? 0),
            )
            .toInt();

    return Scaffold(
      appBar: AppBar(title: const Text('Horas Culminadas')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: Text(
                        '$totalHoras',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _horas.length,
                      itemBuilder: (context, index) {
                        final item = _horas[index];
                        return ListTile(
                          title: Text('Fecha: ${item['fecha']}'),
                          subtitle: Text(
                            'Descripción: ${item['descripcion'] ?? ''}',
                          ),
                          trailing: Text('Horas: ${item['horas']}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final horasController = TextEditingController();
          final descripcionController = TextEditingController();
          final diaController = TextEditingController();
          final mesController = TextEditingController();
          final anioController = TextEditingController();

          final result = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Registrar horas'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: horasController,
                        decoration: const InputDecoration(hintText: 'Horas'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: descripcionController,
                        decoration: const InputDecoration(
                          hintText: 'Descripción',
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller: diaController,
                              decoration: const InputDecoration(
                                hintText: 'Día',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: TextField(
                              controller: mesController,
                              decoration: const InputDecoration(
                                hintText: 'Mes',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: TextField(
                              controller: anioController,
                              decoration: const InputDecoration(
                                hintText: 'Año',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
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
              );
            },
          );

          if (result == true &&
              horasController.text.trim().isNotEmpty &&
              descripcionController.text.trim().isNotEmpty &&
              diaController.text.trim().isNotEmpty &&
              mesController.text.trim().isNotEmpty &&
              anioController.text.trim().isNotEmpty) {
            DateTime? fecha;
            try {
              fecha = DateTime(
                int.parse(anioController.text.trim()),
                int.parse(mesController.text.trim()),
                int.parse(diaController.text.trim()),
              );
            } catch (_) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Fecha inválida')));
              return;
            }
            await _supabaseService.registrarHoras(
              idEstudiante: widget.idEstudiante,
              fecha: fecha,
              horas: int.tryParse(horasController.text.trim()) ?? 0,
              descripcion: descripcionController.text.trim(),
              // actividad: 'opcional',
            );
            await cargarHoras();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Horas registradas')));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
