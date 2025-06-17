import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HelpRequestScreen extends StatefulWidget {
  const HelpRequestScreen({Key? key}) : super(key: key);

  @override
  State<HelpRequestScreen> createState() => _HelpRequestScreenState();
}

class _HelpRequestScreenState extends State<HelpRequestScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _loading = false;
  String _statusMessage = '';

  // Definimos un Future para las solicitudes de ayuda
  late Future<List<Map<String, dynamic>>> _helpRequestsFuture;

  @override
  void initState() {
    super.initState();
    // Inicializamos el Future en initState para cargar las solicitudes al inicio
    _helpRequestsFuture = _loadHelpRequests();
  }

  // Función para cargar las solicitudes de ayuda desde Supabase
  Future<List<Map<String, dynamic>>> _loadHelpRequests() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      // Si no hay usuario, retornamos una lista vacía para evitar errores
      return [];
    }

    try {
      final List<Map<String, dynamic>> response = await Supabase.instance.client
          .from('help_requests')
          .select()
          .eq('student_id', user.id)
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      // Puedes manejar el error como prefieras, por ejemplo, lanzarlo o registrarlo
      print('Error al cargar solicitudes: $e');
      throw Exception('No se pudieron cargar las solicitudes.');
    }
  }

  // Función para enviar una nueva solicitud de ayuda
  Future<void> _sendHelpRequest() async {
    setState(() {
      _loading = true;
      _statusMessage = '';
    });

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      setState(() {
        _loading = false;
        _statusMessage = 'Usuario no autenticado.';
      });
      return;
    }

    try {
      await Supabase.instance.client.from('help_requests').insert({
        'descripcion': _descriptionController.text,
        'estado': 'enviada',
        'student_id': user.id,
        'created_at': DateTime.now().toIso8601String(),
      });

      setState(() {
        _statusMessage = 'Solicitud enviada con éxito 🎉';
        _descriptionController.clear();
        // Al enviar una solicitud, recargamos el Future para que el FutureBuilder se actualice
        _helpRequestsFuture = _loadHelpRequests();
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al enviar la solicitud: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Función para cancelar una solicitud existente
  Future<void> _cancelRequest(String requestId) async {
    try {
      await Supabase.instance.client
          .from('help_requests')
          .update({'estado': 'cancelada'})
          .eq('id', requestId);

      setState(() {
        _statusMessage = 'Solicitud cancelada';
        // Al cancelar una solicitud, recargamos el Future para que el FutureBuilder se actualice
        _helpRequestsFuture = _loadHelpRequests();
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al cancelar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar Ayuda')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción de la solicitud',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _sendHelpRequest,
              child:
                  _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enviar Solicitud'),
            ),
            const SizedBox(height: 16),
            Text(_statusMessage, style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 24),
            const Text(
              'Historial de Solicitudes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              // Usamos FutureBuilder para manejar la carga y visualización del historial
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _helpRequestsFuture, // El Future que queremos observar
                builder: (context, snapshot) {
                  // Muestra un indicador de carga mientras los datos se están obteniendo
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // Muestra un mensaje de error si algo sale mal
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Muestra un mensaje si no hay solicitudes
                    return const Center(
                      child: Text('Aún no has hecho ninguna solicitud.'),
                    );
                  } else {
                    // Si tenemos datos, los mostramos en un ListView
                    final requests = snapshot.data!;
                    return ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            title: Text(
                              request['descripcion'] ?? 'Sin descripción',
                            ),
                            subtitle: Text(
                              'Estado: ${request['estado']}',
                              style: TextStyle(
                                color:
                                    request['estado'] == 'cancelada'
                                        ? Colors.red
                                        : Colors.black,
                              ),
                            ),
                            trailing:
                                request['estado'] == 'enviada'
                                    ? IconButton(
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => _cancelRequest(
                                            request['id'].toString(),
                                          ), // Asegúrate que 'id' se trate como String (UUID)
                                    )
                                    : null,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
