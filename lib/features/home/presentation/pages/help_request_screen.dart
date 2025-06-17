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
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadHelpRequests();
  }

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
      });

      _loadHelpRequests(); // Recargar historial
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

  Future<void> _loadHelpRequests() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('help_requests')
        .select()
        .eq('student_id', user.id)
        .order('created_at', ascending: false);

    setState(() {
      _requests = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _cancelRequest(String requestId) async {
    try {
      await Supabase.instance.client
          .from('help_requests')
          .update({'estado': 'cancelada'})
          .eq('id', requestId);

      _loadHelpRequests(); // Recargar lista
      setState(() {
        _statusMessage = 'Solicitud cancelada';
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor, // Color de fondo del tema
                foregroundColor: Colors.white, // Texto blanco
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                  )
              ),
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
              child:
                  _requests.isEmpty
                      ? const Text('Aún no has hecho ninguna solicitud.')
                      : ListView.builder(
                        itemCount: _requests.length,
                        itemBuilder: (context, index) {
                          final request = _requests[index];
                          return Card(
                            child: ListTile(
                              title: Text(request['descripcion'] ?? ''),
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
                                            () => _cancelRequest(request['id']),
                                      )
                                      : null,
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
