import 'package:flutter/material.dart';

// NO SE INCLUYEN DEPENDENCIAS EXTERNAS NI ESPECÍFICAS DE TU PROYECTO
// como 'package:provider', 'package:supabase_flutter', 'package:intl',
// o tus modelos y servicios personalizados.
// ESTE CÓDIGO ES SOLO PARA VISUALIZAR LA INTERFAZ.

// --- INICIO DE MODELO ESQUELETO (SOLO PARA COMPILAR LA UI) ---
// Normalmente, este modelo estaría en un archivo separado (profile_model.dart)
// y tendría una lógica más compleja con ChangeNotifier.
class ProfileModel {
  final formKey = GlobalKey<FormState>();

  // Controladores y variables de estado (solo inicializados para evitar errores de compilación)
  final TextEditingController fullNameController = TextEditingController(text: 'John Doe');
  final TextEditingController carnetController = TextEditingController(text: '202012345');
  final TextEditingController avatarUrlController = TextEditingController(text: 'https://cdn.icon-icons.com/icons2/1378/PNG/512/avatar_100994.png');
  final TextEditingController emailController = TextEditingController(text: 'john.doe@example.com');

  String? selectedGender = 'Male';
  String? selectedUserType = 'student'; // Para mostrar los campos de estudiante por defecto
  DateTime? selectedBirthDate = DateTime(2000, 1, 15);
  DateTime? selectedAdmissionTrimester = DateTime(2020, 9, 1); // 1 de Septiembre
  int? selectedCareerId = 1; // Asumimos que existe alguna carrera con ID 1
  int? selectedAssistanceTypeId = 1; // Asumimos que existe algún tipo de asistencia con ID 1

  void dispose() {
    fullNameController.dispose();
    carnetController.dispose();
    avatarUrlController.dispose();
    emailController.dispose();
  }

  // Métodos placeholder para inicializar y actualizar (no funcionales aquí)
  void initializeControllers(dynamic user, dynamic studentData) {
    // La lógica real estaría aquí para cargar datos
  }
}

// --- FIN DE MODELO ESQUELETO ---

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false; // Solo para controlar el indicador de carga visualmente

  // Métodos placeholder para servicios (no funcionales)
  // En una aplicación real, usarías los servicios reales.
  List<dynamic> _careers = [{'id': 1, 'name': 'Ingeniería de Software'}, {'id': 2, 'name': 'Diseño Gráfico'}];
  List<dynamic> _assistanceTypes = [{'id': 1, 'name': 'Asistencia Completa'}, {'id': 2, 'name': 'Asistencia Parcial'}];


  @override
  void initState() {
    super.initState();
    _model = ProfileModel(); // Instancia del modelo esqueleto
    // En una aplicación real, aquí llamarías a _loadProfileData();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Métodos placeholder sin funcionalidad real de datos
  void _loadProfileData() {
    // No hace nada, solo para evitar errores de compilación
  }

  void _saveProfile() {
    if (_model.formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      // Simular un guardado
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil guardado (simulado)!')),
        );
      });
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime? initialDate, Function(DateTime?) onSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // Simular la actualización del modelo
      setState(() {
        _model.selectedBirthDate = picked;
      });
    }
  }

  Future<void> _selectAdmissionTrimester(BuildContext context, DateTime? initialDate, Function(DateTime?) onSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      // Simular la actualización del modelo
      if (picked.day == 1 && (picked.month == 1 || picked.month == 5 || picked.month == 9)) {
        setState(() {
          _model.selectedAdmissionTrimester = picked;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La fecha de admisión debe ser el día 1 de Enero, Mayo o Septiembre.')),
        );
      }
    }
  }

  void logout() async {
    // Lógica de logout simulada
    print("Logout (simulado)");
    // Navigator.of(context).pushReplacementNamed('/login'); // Comentado, ya que no hay rutas definidas
  }

  @override
  Widget build(BuildContext context) {
    // final currentEmail = authService.getCurrentUserEmail(); // No disponible sin AuthService

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[100], // Color de fondo simple
        appBar: AppBar(
          backgroundColor: const Color(0xFFD87B21), // Color fijo para el AppBar
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: logout,
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
          ],
          centerTitle: true,
          elevation: 2,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                top: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _model.formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Sección de Foto de Perfil
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: _model.avatarUrlController.text.isNotEmpty
                                    ? NetworkImage(_model.avatarUrlController.text)
                                    : null,
                                child: _model.avatarUrlController.text.isEmpty
                                    ? Icon(Icons.person, size: 60, color: Colors.grey.shade600)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.blueAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Funcionalidad para cambiar foto de perfil en desarrollo.')),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Campos de Usuario (simulados)
                        TextFormField(
                          controller: _model.emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          readOnly: true,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _model.fullNameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre Completo',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El nombre completo es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _model.selectedGender,
                          decoration: InputDecoration(
                            labelText: 'Género',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: const <String>['Male', 'Female', 'Other', 'Undefined']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _model.selectedGender = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El género es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400, width: 1),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            title: Text(
                              _model.selectedBirthDate == null
                                  ? 'Fecha de Nacimiento'
                                  : 'Fecha de Nacimiento: ${ _model.selectedBirthDate!.toIso8601String().split('T').first}', // Formato simple sin intl
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(
                              context,
                              _model.selectedBirthDate,
                              (date) => _model.selectedBirthDate = date,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _model.selectedUserType,
                          decoration: InputDecoration(
                            labelText: 'Tipo de Usuario',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: const <String>['student', 'professor', 'admin']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _model.selectedUserType = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El tipo de usuario es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Campos de Estudiante (simulados) - Mostrar solo si userType es 'student'
                        if (_model.selectedUserType == 'student') ...[
                          Divider(height: 32, thickness: 1, color: Colors.grey.shade300),
                          Text('Datos de Estudiante', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _model.carnetController,
                            decoration: InputDecoration(
                              labelText: 'Carnet',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (_model.selectedUserType == 'student' && (value == null || value.isEmpty)) {
                                return 'El carnet es obligatorio para estudiantes';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _model.avatarUrlController,
                            decoration: InputDecoration(
                              labelText: 'URL del Avatar',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.url,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400, width: 1),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: ListTile(
                              title: Text(
                                _model.selectedAdmissionTrimester == null
                                    ? 'Fecha de Admisión (Enero, Mayo o Septiembre día 1)'
                                    : 'Admisión: ${ _model.selectedAdmissionTrimester!.toIso8601String().split('T').first}', // Formato simple sin intl
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () => _selectAdmissionTrimester(
                                context,
                                _model.selectedAdmissionTrimester,
                                (date) => _model.selectedAdmissionTrimester = date,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _model.selectedCareerId,
                            decoration: InputDecoration(
                              labelText: 'Carrera',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: _careers.map((career) {
                              return DropdownMenuItem<int>(
                                value: career['id'] as int,
                                child: Text(career['name'] as String),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              setState(() {
                                _model.selectedCareerId = newValue;
                              });
                            },
                            validator: (value) {
                              if (_model.selectedUserType == 'student' && value == null) {
                                return 'La carrera es obligatoria para estudiantes';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _model.selectedAssistanceTypeId,
                            decoration: InputDecoration(
                              labelText: 'Tipo de Asistencia',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: _assistanceTypes.map((type) {
                              return DropdownMenuItem<int>(
                                value: type['id'] as int,
                                child: Text(type['name'] as String),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              setState(() {
                                _model.selectedAssistanceTypeId = newValue;
                              });
                            },
                            validator: (value) {
                              if (_model.selectedUserType == 'student' && value == null) {
                                return 'El tipo de asistencia es obligatorio para estudiantes';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 32),

                        // Botón de Guardar
                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            backgroundColor: const Color(0xFFD87B21),
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Guardar Perfil',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}