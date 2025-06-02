// lib/features/auth/presentation/pages/profile_page.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/main.dart';
import 'package:ayudantia_software/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ayudantia_software/features/auth/data/models/user_profile_model.dart';
import 'package:ayudantia_software/features/auth/data/models/student_profile_model.dart';
import 'package:ayudantia_software/features/auth/data/models/career_model.dart';
import 'package:ayudantia_software/features/auth/data/models/assistance_type_model.dart';
import 'package:ayudantia_software/features/auth/presentation/pages/login_page.dart';
import 'package:ayudantia_software/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:collection/collection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

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

  final _carnetController = TextEditingController();
  final _admissionTrimesterController = TextEditingController();

  UserProfileModel? _userProfile;
  StudentProfileModel? _studentProfile;

  List<CareerModel> _careers = [];
  List<AssistanceTypeModel> _assistanceTypes = [];

  int? _selectedCareerId;
  int? _selectedAssistanceTypeId;

  bool _isLoadingProfile = true;
  bool _isUpdatingProfile = false;

  late final AuthRemoteDataSource _authDataSource;

  @override
  void initState() {
    super.initState();

    _authDataSource = AuthRemoteDataSourceImpl(supabase);
    _loadUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _userTypeController.dispose();

    _carnetController.dispose();
    _admissionTrimesterController.dispose();

    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });

    final User? currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay usuario autenticado.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
      return;
    }

    try {
      _assistanceTypes = await _authDataSource.getAssistanceTypes();
      _assistanceTypes.sort((a, b) => a.type.compareTo(b.type));
      print('DEBUG: Fetched ${_assistanceTypes.length} assistance types.');

      final UserProfileModel? generalProfile =
          await _authDataSource.getUserProfile(currentUser.id);

      if (mounted) {
        if (generalProfile != null) {
          _userProfile = generalProfile;
          _fullNameController.text = _userProfile?.fullName ?? '';
          _birthDateController.text = _userProfile?.birthDate != null
              ? _userProfile!.birthDate!.toIso8601String().split('T').first
              : '';
          _genderController.text = _userProfile?.gender ?? '';
          _userTypeController.text = _userProfile?.userType ?? '';

          print('DEBUG: UserType: ${_userProfile?.userType}');

          if (_userProfile?.userType == 'Student') {
            final StudentProfileModel? studentProfile = await _authDataSource.getStudentProfile(currentUser.id);
            if (mounted) {
              if (studentProfile != null) {
                _studentProfile = studentProfile;
                _carnetController.text = _studentProfile?.carnet ?? '';
                _selectedCareerId = _studentProfile?.careerId; 
                _selectedAssistanceTypeId = _studentProfile?.assistanceTypeId;

                int? usersFacultyId; 
                if (_selectedCareerId != null) {
                  final allCareersForLookup = await _authDataSource.getCareers(); 
                  print('DEBUG: Fetched ${allCareersForLookup.length} total careers to find user\'s faculty.');
                  final currentCareer = allCareersForLookup.firstWhereOrNull(
                    (career) => career.careerId == _selectedCareerId,
                  );
                  usersFacultyId = currentCareer?.idFaculty; 
                  print('DEBUG: Current career (${currentCareer?.name}) facultyId: $usersFacultyId');
                }
                
                _careers = await _authDataSource.getCareers(facultyId: usersFacultyId);
                _careers.sort((a, b) => a.name.compareTo(b.name));
                print('DEBUG: Loaded ${_careers.length} careers (filtered by faculty ID: $usersFacultyId).');

                _admissionTrimesterController.text = _studentProfile?.admissionTrimester != null
                    ? _studentProfile!.admissionTrimester!.toIso8601String().split('T').first
                    : '';
              } else {
                _studentProfile = StudentProfileModel(id: currentUser.id);
                await _authDataSource.createStudentProfile(_studentProfile!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Perfil de estudiante creado automáticamente.'), backgroundColor: Colors.orange),
                  );
                }
                _selectedCareerId = null; 
                _selectedAssistanceTypeId = null; 
                _careers = await _authDataSource.getCareers(); 
                _careers.sort((a, b) => a.name.compareTo(b.name));
                print('DEBUG: New student. Loaded ${_careers.length} unfiltered careers.');
              }
            }
          }
          
        } else {
          String initialUserType = 'Other';
          if (currentUser.email!.endsWith('@correo.unimet.edu.ve')) {
            initialUserType = 'Student';
          } else if (currentUser.email!.endsWith('@unimet.edu.ve')) {
            initialUserType = 'Professor';
          }

          _userProfile = UserProfileModel(
            id: currentUser.id,
            email: currentUser.email!,
            userType: initialUserType,
          );
          try {
            await _authDataSource.createUserProfile(_userProfile!);
            
            if (initialUserType == 'Student') {
              await _authDataSource.createStudentProfile(StudentProfileModel(id: currentUser.id));
              _selectedCareerId = null;
              _selectedAssistanceTypeId = null;
              _careers = await _authDataSource.getCareers(); 
              _careers.sort((a, b) => a.name.compareTo(b.name));
              print('DEBUG: New student profile created. Loaded ${_careers.length} unfiltered careers.');
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil general y de usuario específico creados automáticamente.'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            _loadUserProfile(); 
            return;
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al crear perfil automáticamente: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('ERROR: Exception in _loadUserProfile: $e'); 
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _updateUserProfile() async {
    setState(() {
      _isUpdatingProfile = true;
    });

    final User? currentUser = supabase.auth.currentUser;
    if (currentUser == null || _userProfile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay usuario para actualizar.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isUpdatingProfile = false;
      });
      return;
    }

    try {
      final updatedGeneralProfile = UserProfileModel(
        id: _userProfile!.id,
        email: _userProfile!.email,
        fullName: _fullNameController.text.trim().isNotEmpty ? _fullNameController.text.trim() : null,
        birthDate: _birthDateController.text.trim().isNotEmpty ? DateTime.tryParse(_birthDateController.text.trim()) : null,
        gender: _genderController.text.trim().isNotEmpty ? _genderController.text.trim() : null,
        userType: _userProfile!.userType,
      );
      await _authDataSource.updateUserProfile(updatedGeneralProfile);

      if (_userProfile?.userType == 'Student' && _studentProfile != null) {
        final updatedStudentProfile = StudentProfileModel(
          id: _userProfile!.id,
          carnet: _carnetController.text.trim().isNotEmpty ? _carnetController.text.trim() : null,
          careerId: _selectedCareerId, 
          assistanceTypeId: _selectedAssistanceTypeId,
          admissionTrimester: _admissionTrimesterController.text.trim().isNotEmpty ? DateTime.tryParse(_admissionTrimesterController.text.trim()) : null,
          avatarUrl: _studentProfile?.avatarUrl,
        );
        await _authDataSource.updateStudentProfile(updatedStudentProfile);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUserProfile(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('ERROR: Exception in _updateUserProfile: $e'); 
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingProfile = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty
          ? DateTime.tryParse(controller.text) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T').first;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadAvatar() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    try {
      final String fileExt = path.extension(image.path);
      final String fileName = '${_userProfile!.id}$fileExt';
      // CAMBIO AQUÍ: Añadir 'news/' al path
      final String imagePathInBucket = 'news/$fileName'; 

      final Uint8List fileBytes = await image.readAsBytes();

      await supabase.storage.from('avatars').uploadBinary(
            imagePathInBucket,
            fileBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String publicUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(imagePathInBucket);

      if (_userProfile?.userType == 'Student' && _studentProfile != null) {
        _studentProfile = _studentProfile!.copyWith(avatarUrl: publicUrl);
        await _authDataSource.updateStudentProfile(_studentProfile!);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avatar actualizado exitosamente!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir el avatar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('ERROR: Exception in _uploadAvatar: $e');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final String? currentUserType = _userProfile?.userType;
    final bool isStudent = currentUserType == 'Student';

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
            if (isStudent) ...[
              Center(
                child: GestureDetector(
                  onTap: _uploadAvatar,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    backgroundImage: (_studentProfile?.avatarUrl != null && _studentProfile!.avatarUrl!.isNotEmpty)
                        ? NetworkImage(_studentProfile!.avatarUrl!) as ImageProvider<Object>?
                        : null,
                    child: (_studentProfile?.avatarUrl == null || _studentProfile!.avatarUrl!.isEmpty)
                        ? Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

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
              onTap: () => _selectDate(context, _birthDateController),
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

            if (isStudent) ...[
              const Text(
                'Información de Estudiante',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _carnetController,
                labelText: 'Carnet',
                prefixIcon: Icons.card_membership,
                keyboardType: TextInputType.text,
                maxLength: 20,
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Carrera',
                  prefixIcon: const Icon(Icons.school),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                  ),
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  filled: true,
                ),
                value: _selectedCareerId,
                hint: const Text('Selecciona una carrera'),
                items: _careers.map((career) {
                  return DropdownMenuItem<int>(
                    value: career.careerId,
                    child: Text(career.name),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedCareerId = newValue;
                  });
                  print('DEBUG: Selected Career ID: $_selectedCareerId');
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona una carrera';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Tipo de Asistencia',
                  prefixIcon: const Icon(Icons.help_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                  ),
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  filled: true,
                ),
                value: _selectedAssistanceTypeId,
                hint: const Text('Selecciona un tipo de asistencia'),
                items: _assistanceTypes.map((type) {
                  return DropdownMenuItem<int>(
                    value: type.assistanceTypeId,
                    child: Text(type.type),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedAssistanceTypeId = newValue;
                  });
                  print('DEBUG: Selected Assistance Type ID: $_selectedAssistanceTypeId');
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona un tipo de asistencia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              CustomTextField(
                controller: _admissionTrimesterController,
                labelText: 'Trimestre de Admisión (YYYY-MM-DD)',
                prefixIcon: Icons.date_range,
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: () => _selectDate(context, _admissionTrimesterController),
              ),
              const SizedBox(height: 20),
            ],
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUpdatingProfile ? null : _updateUserProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isUpdatingProfile
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