import 'package:flutter/material.dart';
import 'package:ayudantia_software/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HorasCulminadasScreen extends StatefulWidget {
  const HorasCulminadasScreen({super.key});

  @override
  State<HorasCulminadasScreen> createState() => _HorasCulminadasScreenState();
}

class _HorasCulminadasScreenState extends State<HorasCulminadasScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _horas = [];
  late final String idEstudiante; // Cambia aquí

  Future<void> registrarHoras(
    DateTime fecha,
    int horas,
    String descripcion,
  ) async {
    await _supabaseService.registrarHoras(
      idEstudiante: idEstudiante,
      fecha: fecha,
      horas: horas,
      descripcion: descripcion,
    );
    await cargarHoras();
  }

  Future<void> cargarHoras() async {
    final horas = await _supabaseService.obtenerHorasPorIdEstudiante(
      idEstudiante,
    );
    setState(() {
      _horas = horas;
    });
  }

  Future<void> editarHora(Map<String, dynamic> hora) async {
    final horasController = TextEditingController(
      text: hora['horas'].toString(),
    );
    final descripcionController = TextEditingController(
      text: hora['descripcion'] ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar horas'),
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
                  decoration: const InputDecoration(hintText: 'Descripción'),
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
        descripcionController.text.trim().isNotEmpty) {
      await _supabaseService.editarHoraCulminada(
        hora['idhora'],
        DateTime.parse(hora['fecha']),
        int.tryParse(horasController.text.trim()) ?? 0,
        descripcionController.text.trim(),
      );
      await cargarHoras();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hora editada')));
    }
  }

  @override
  void initState() {
    super.initState();
    idEstudiante = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (idEstudiante.isEmpty) {
      // Manejar caso de usuario no autenticado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado')),
        );
      });
      return;
    }
    cargarHoras();
  }

  @override
  Widget build(BuildContext context) {
    int totalHoras = _horas.fold(
      0,
      (sum, item) =>
          sum +
          (item['horas'] is int
              ? item['horas'] as int
              : int.tryParse(item['horas']?.toString() ?? '0') ?? 0),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Text(
                '$totalHoras',
                style: const TextStyle(fontSize: 32, color: Colors.white),
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
                  subtitle: Text('Descripción: ${item['descripcion'] ?? ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Horas: ${item['horas']}'),
                      if (index == 0) ...[
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await editarHora(item);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.orange,
                          ),
                          tooltip: 'Restar horas',
                          onPressed: () async {
                            final restarController = TextEditingController();
                            final descripcionController =
                                TextEditingController();
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Restar horas'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: restarController,
                                        decoration: const InputDecoration(
                                          hintText: 'Horas a restar',
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                      TextField(
                                        controller: descripcionController,
                                        decoration: const InputDecoration(
                                          hintText: 'Motivo o descripción',
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('Restar'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (result == true &&
                                restarController.text.trim().isNotEmpty &&
                                int.tryParse(restarController.text.trim()) !=
                                    null) {
                              await registrarHoras(
                                DateTime.now(),
                                -int.parse(restarController.text.trim()),
                                descripcionController.text.trim().isNotEmpty
                                    ? descripcionController.text.trim()
                                    : 'Corrección/resta de horas',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Horas restadas')),
                              );
                            }
                          },
                        ),
                      ],
                    ],
                  ),
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
          DateTime? fechaSeleccionada;

          final result = await showDialog<bool>(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder:
                    (context, setStateDialog) => AlertDialog(
                      title: const Text('Registrar horas'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: horasController,
                              decoration: const InputDecoration(
                                hintText: 'Horas',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            TextField(
                              controller: descripcionController,
                              decoration: const InputDecoration(
                                hintText: 'Descripción',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('Fecha: '),
                                Text(
                                  fechaSeleccionada != null
                                      ? '${fechaSeleccionada!.toLocal()}'.split(
                                        ' ',
                                      )[0]
                                      : 'No seleccionada',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      setStateDialog(() {
                                        fechaSeleccionada = picked;
                                      });
                                    }
                                  },
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
                    ),
              );
            },
          );

          if (result == true &&
              horasController.text.trim().isNotEmpty &&
              descripcionController.text.trim().isNotEmpty &&
              fechaSeleccionada != null) {
            await registrarHoras(
              fechaSeleccionada!,
              int.tryParse(horasController.text.trim()) ?? 0,
              descripcionController.text.trim(),
            );
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
