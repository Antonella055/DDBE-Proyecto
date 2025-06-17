import 'package:ayudantia_software/features/auth/data/models/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/features/auth/data/models/student_profile_model.dart';

class AdminCreateStudent extends StatefulWidget {
  const AdminCreateStudent({super.key});
  @override
  State<AdminCreateStudent> createState() => _AdminCreateStudentState();
}

class _AdminCreateStudentState extends State<AdminCreateStudent> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _carnetController = TextEditingController();
  final _admissionTrimesterController = TextEditingController();
  final _fullNameController = TextEditingController();

  int? _selectedCareerId;
  int? _selectedAssistanceTypeId;
  String? _selectedAvatarUrl;

  List<Map<String, dynamic>> _careers = [];
  List<Map<String, dynamic>> _assistanceTypes = [];

  @override
  void initState() {
    super.initState();
    _loadCareersAndTypes();
  }

  Future<void> _loadCareersAndTypes() async {
    final careers = await Supabase.instance.client.from('careers').select();
    final types = await Supabase.instance.client.from('assistance_types').select();
    setState(() {
      _careers = List<Map<String, dynamic>>.from(careers);
      _assistanceTypes = List<Map<String, dynamic>>.from(types);
    });
  }

  Future<void> _createStudent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCareerId == null || _selectedAssistanceTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar carrera y tipo de asistencia')),
      );
      return;
    }

    AuthResponse? res;

    try {
    
    // 1. Crear el usuario en auth
      res = await Supabase.instance.client.auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      data: {'role': 'student'},
    );} catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear usuario: ${e.toString()}')),
      );
      return;
    }



     final profile = UserProfileModel(
        id: res.user!.id,
        userType: 'Student',
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
      );

      await Supabase.instance.client.from('profiles').insert(profile.toJson());
  

      final student = StudentProfileModel(
        id: res.user!.id,
        carnet: _carnetController.text.trim(),
        careerId: _selectedCareerId,
        assistanceTypeId: _selectedAssistanceTypeId,
        admissionTrimester: _admissionTrimesterController.text.isNotEmpty
            ? DateTime.parse(_admissionTrimesterController.text)
            : null,
        avatarUrl: _selectedAvatarUrl,
      );

      await Supabase.instance.client.from('students').insert(student.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estudiante creado exitosamente')),
      );
      Navigator.pop(context);
     
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Estudiante')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email*'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña*'),
                validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                obscureText: true,
              ),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Nombre completo*'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _carnetController,
                decoration: const InputDecoration(labelText: 'Carnet*'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              DropdownButtonFormField<int>(
                value: _selectedCareerId,
                decoration: const InputDecoration(labelText: 'Carrera*'),
                items: _careers.map((career) {
                  return DropdownMenuItem<int>(
                    value: career['career_id'] as int,
                    child: Text(career['name'] as String),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                  _selectedCareerId = value;
                }),
              ),
              DropdownButtonFormField<int>(
                value: _selectedAssistanceTypeId,
                decoration: const InputDecoration(labelText: 'Tipo de Asistencia*'),
                items: _assistanceTypes.map((type) {
                  return DropdownMenuItem<int>(
                    value: type['assistance_type_id'] as int,
                    child: Text(type['type'] as String),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                  _selectedAssistanceTypeId = value;
                }),
              ),
              TextFormField(
                controller: _admissionTrimesterController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Trimestre de Admisión (YYYY-MM-DD)'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _admissionTrimesterController.text = DateFormat('yyyy-MM-dd').format(date);
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createStudent,
                child: const Text('Crear Estudiante'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

