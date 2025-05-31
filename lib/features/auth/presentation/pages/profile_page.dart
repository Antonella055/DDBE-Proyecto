import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/main.dart'; 
import 'package:ayudantia_software/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ayudantia_software/features/auth/data/models/user_profile_model.dart';
import 'package:ayudantia_software/features/auth/presentation/pages/login_page.dart';
import 'package:ayudantia_software/features/auth/presentation/widgets/custom_text_field.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _fullNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _genderController = TextEditingController();
  final _userTypeController = TextEditingController();

  UserProfileModel? _userProfile;
  bool _isLoadingProfile = true;
  bool _isSaving = false;

  late final AuthRemoteDataSource _authDataSource;

  @override
  void initState() {
    super.initState();
    print('DEBUG_INIT: ProfilePage initState - Inicio de initState.');

    if (supabase == null) {
      print('ERROR_INIT: La instancia global de Supabase es NULL en ProfilePage initState.');
      if (mounted) {
        context.showSnackBar('Error: Supabase no inicializado correctamente.', isError: true);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
      }
      return; 
    }

    _authDataSource = AuthRemoteDataSourceImpl(supabase);
    print('DEBUG_INIT: ProfilePage initState - AuthRemoteDataSourceImpl inicializado.');

    print('DEBUG_INIT: ProfilePage initState - Llamando _loadUserProfile().');
    _loadUserProfile();
    print('DEBUG_INIT: ProfilePage initState - Fin de initState.');
  }

  Future<void> _loadUserProfile() async {
    print('DEBUG_LOAD: _loadUserProfile - ¡ENTRADA REAL A LA FUNCIÓN!');
    setState(() {
      _isLoadingProfile = true;
      print('DEBUG_LOAD: _loadUserProfile - _isLoadingProfile establecido en true DENTRO DE SETSTATE.');
    });

    print('DEBUG_LOAD: _loadUserProfile - Ejecución CONTINÚA después de setState (sin delay).'); 

    final User? currentUser = supabase.auth.currentUser;
    print('DEBUG_LOAD: _loadUserProfile - currentUser: ${currentUser?.id ?? 'Nulo'}');

    if (currentUser == null) {
      print('DEBUG_LOAD: _loadUserProfile - No hay usuario autenticado, redirigiendo a LoginPage.');
      if (mounted) {
        context.showSnackBar('No hay usuario autenticado.', isError: true);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          print('DEBUG_LOAD: _loadUserProfile - _isLoadingProfile establecido en false. (Usuario Nulo)');
        });
      }
      return;
    }

    try {
      print('DEBUG_LOAD: _loadUserProfile - Intentando obtener perfil de Supabase para ID: ${currentUser.id}'); // ESTE ES EL SIGUIENTE PRINT CLAVE
      final UserProfileModel? profile =
          await _authDataSource.getUserProfile(currentUser.id); 

      print('DEBUG_LOAD: _loadUserProfile - getUserProfile ha retornado.');

      if (mounted) {
        if (profile != null) {
          _userProfile = profile;
          _fullNameController.text = _userProfile?.fullName ?? '';
          _birthDateController.text = _userProfile?.birthDate != null
              ? _userProfile!.birthDate!.toIso8601String().split('T').first
              : '';
          _genderController.text = _userProfile?.gender ?? '';
          _userTypeController.text = _userProfile?.userType ?? '';
          print('DEBUG_LOAD: _loadUserProfile - Perfil cargado y controladores actualizados.');
        } else {
          print('DEBUG_LOAD: _loadUserProfile - Perfil no encontrado, intentando crear uno básico.');
          _userProfile = UserProfileModel(
            id: currentUser.id,
            email: currentUser.email!,
          );
          try {
            await _authDataSource.createUserProfile(_userProfile!);
            if (mounted) {
              context.showSnackBar('Perfil creado automáticamente.');
            }
            print('DEBUG_LOAD: _loadUserProfile - Perfil básico creado exitosamente.');
          } catch (e) {
            if (mounted) {
              context.showSnackBar('Error al crear perfil automáticamente: $e', isError: true);
            }
            print('ERROR_LOAD: _loadUserProfile - Fallo en la creación automática de perfil: $e');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Error al cargar el perfil: $e', isError: true);
      }
      print('ERROR_LOAD: _loadUserProfile - Fallo en la carga del perfil (catch principal): $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          print('DEBUG_LOAD: _loadUserProfile - _isLoadingProfile establecido en false. FIN.');
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isSaving = true;
    });

    final User? currentUser = supabase.auth.currentUser;
    if (currentUser == null || _userProfile == null) {
      if (mounted) {
        context.showSnackBar('No hay usuario para actualizar.', isError: true);
      }
      setState(() {
        _isSaving = false;
      });
      return;
    }

    final updatedProfile = UserProfileModel(
      id: _userProfile!.id,
      email: _userProfile!.email,
      fullName: _fullNameController.text.trim().isNotEmpty
          ? _fullNameController.text.trim()
          : null,
      birthDate: _birthDateController.text.trim().isNotEmpty
          ? DateTime.tryParse(_birthDateController.text.trim())
          : null,
      gender: _genderController.text.trim().isNotEmpty
          ? _genderController.text.trim()
          : null,
      userType: _userTypeController.text.trim().isNotEmpty
          ? _userTypeController.text.trim()
          : null,
    );

    try {
      await _authDataSource.updateFullUserProfile(updatedProfile);
      if (mounted) {
        context.showSnackBar('Perfil actualizado exitosamente!');
        _loadUserProfile(); 
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Error al actualizar el perfil: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDateController.text.isNotEmpty
          ? DateTime.tryParse(_birthDateController.text) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        context.showSnackBar(error.message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Error al cerrar sesión: $e', isError: true);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _userTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mi Perfil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Correo Electrónico:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: TextEditingController(text: _userProfile?.email ?? 'N/A'),
              labelText: 'Email',
              prefixIcon: Icons.email,
              enabled: false, 
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            Text(
              'Nombre Completo:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _fullNameController,
              labelText: 'Nombre Completo',
              prefixIcon: Icons.person,
              maxLength: 100,
            ),
            const SizedBox(height: 20),

            Text(
              'Fecha de Nacimiento:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _birthDateController,
              labelText: 'Fecha de Nacimiento (YYYY-MM-DD)',
              prefixIcon: Icons.calendar_today,
              readOnly: true, 
              onTap: () => _selectDate(context), 
            ),
            const SizedBox(height: 20),

         
            Text(
              'Género:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _genderController,
              labelText: 'Género',
              prefixIcon: Icons.person_outline,
              maxLength: 50,
            ),
            const SizedBox(height: 20),

            
            Text(
              'Tipo de Usuario:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _userTypeController,
              labelText: 'Tipo de Usuario',
              prefixIcon: Icons.category,
              enabled: false,
              maxLength: 50,
            ),
            const SizedBox(height: 30),

            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Actualizar Perfil'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}