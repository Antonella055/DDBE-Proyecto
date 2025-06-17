import 'package:ayudantia_software/features/auth/data/models/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/features/auth/data/models/professor_profile_model.dart';

class AdminCreateProfessor extends StatefulWidget {
  const AdminCreateProfessor({super.key});
  @override
  State<AdminCreateProfessor> createState() => _AdminCreateProfessorState();
}

class _AdminCreateProfessorState extends State<AdminCreateProfessor> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _hireDateController = TextEditingController();

  int? _selectedDepartmentId;
  bool _isActive = true;
  List<Map<String, dynamic>> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    final departments = await Supabase.instance.client.from('departments').select();
    setState(() {
      _departments = List<Map<String, dynamic>>.from(departments);
    });
  }

  Future<void> _createProfessor() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar un departamento')),
      );
      return;
    }

    AuthResponse? res;

    try {
      // 1. Crear el usuario en auth
      res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'role': 'professor'},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear usuario: ${e.toString()}')),
      );
      return;
    }

    try {
      // 2. Crear perfil de usuario
      final profile = UserProfileModel(
        id: res.user!.id,
        userType: 'Professor',
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
      );

      await Supabase.instance.client.from('profiles').insert(profile.toJson());

      // 3. Crear perfil de profesor
      final professor = ProfessorProfileModel(
        id: res.user!.id,
        departamentId: _selectedDepartmentId,
        hireDate: _hireDateController.text.isNotEmpty
            ? DateTime.parse(_hireDateController.text)
            : null,
        isActive: _isActive,
      );

      await Supabase.instance.client.from('professors').insert(professor.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profesor creado exitosamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear profesor: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Profesor')),
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
              DropdownButtonFormField<int>(
                value: _selectedDepartmentId,
                decoration: const InputDecoration(labelText: 'Departamento*'),
                items: _departments.map((dept) {
                  return DropdownMenuItem<int>(
                    value: dept['id_department'] as int,
                    child: Text(dept['dpt_name'] as String),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                  _selectedDepartmentId = value;
                }),
              ),
              TextFormField(
                controller: _hireDateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Fecha de Contratación (YYYY-MM-DD)'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _hireDateController.text = DateFormat('yyyy-MM-dd').format(date);
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Activo'),
                value: _isActive,
                onChanged: (value) => setState(() {
                  _isActive = value;
                }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createProfessor,
                child: const Text('Crear Profesor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}