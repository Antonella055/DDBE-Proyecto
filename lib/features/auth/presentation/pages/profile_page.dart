import 'dart:typed_data';
import 'package:ayudantia_software/features/auth/data/models/professor_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/main.dart';
import 'package:ayudantia_software/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ayudantia_software/features/auth/data/models/user_profile_model.dart';
import 'package:ayudantia_software/features/auth/data/models/student_profile_model.dart';
import 'package:ayudantia_software/features/auth/data/models/career_model.dart';
import 'package:ayudantia_software/features/auth/data/models/assistance_type_model.dart';
import 'package:ayudantia_software/features/auth/data/models/department_model.dart';
import 'package:ayudantia_software/features/auth/data/models/faculty_model.dart';
import 'package:ayudantia_software/features/auth/data/models/admin_model.dart';
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

  final _hireDateProfessorController = TextEditingController();

  // Password change controllers
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool? _isActiveProfessor;

  UserProfileModel? _userProfile;
  StudentProfileModel? _studentProfile;
  AdminModel? _adminProfile;

  List<CareerModel> _careers = [];
  List<AssistanceTypeModel> _assistanceTypes = [];
  List<DepartmentModel> _departments = [];
  List<FacultyModel> _faculties = [];

  int? _selectedCareerId;
  int? _selectedAssistanceTypeId;
  int? _selectedDepartmentId;
  int? _selectedFacultyId;

  bool _isLoadingProfile = true;
  bool _isUpdatingProfile = false;

  bool _isUpdatingPassword = false;
  String? _passwordErrorMessage;
  String? _passwordSuccessMessage;
  final _passwordFormKey = GlobalKey<FormState>();

  late final AuthRemoteDataSource _authDataSource;

  @override
  void initState() {
    super.initState();
    _authDataSource = AuthRemoteDataSourceImpl(supabase);
    _loadUserProfile();
    _loadDepartments();
    _loadFaculties();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _userTypeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _carnetController.dispose();
    _admissionTrimesterController.dispose();
    _hireDateProfessorController.dispose();

    super.dispose();
  }

  Future<void> _loadDepartments() async {
    final data = await supabase.from('departments').select().limit(1000);
    if (!mounted) return;
    setState(() {
      _departments = (data as List)
          .map((item) => DepartmentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> _loadFaculties() async {
    final data = await supabase.from('faculty').select().limit(1000);
    if (!mounted) return;
    setState(() {
      _faculties = (data as List)
          .map((item) => FacultyModel.fromJson(item as Map<String, dynamic>))
          .toList();
    });
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
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
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

          if (_userProfile?.userType == 'Admin') {
            final adminProfile = await _authDataSource.getAdmin(currentUser.id);
            if (adminProfile == null) {
              try {
                await _authDataSource.createAdmin(
                  AdminModel(
                    idAdmin: currentUser.id,
                    createdDate: DateTime.now(),
                    isActive: true,
                    role: null,
                    inactiveSince: null,
                  ),
                );
                print('Admin creado automáticamente');
              } catch (e) {
                print('Error al crear admin: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al crear admin: $e')),
                  );
                }
              }
            }
            if (mounted) {
              setState(() {
                _adminProfile = adminProfile;
              });
            }
          }
  

          String expectedUserType = _userProfile!.userType ?? 'Other';
          if (_userProfile!.userType != 'Admin') {
            if (currentUser.email!.endsWith('@correo.unimet.edu.ve')) {
              expectedUserType = 'Student';
            } else if (currentUser.email!.endsWith('@unimet.edu.ve')) {
              expectedUserType = 'Professor';
            }
          }
          if (_userProfile!.userType != expectedUserType) {
            _userProfile = _userProfile!.copyWith(userType: expectedUserType);
            await _authDataSource.updateUserProfile(_userProfile!);
            _userTypeController.text = expectedUserType;
          }

          if (_userProfile?.userType == 'Student') {
            final StudentProfileModel? studentProfile =
                await _authDataSource.getStudentProfile(currentUser.id);
            if (mounted) {
              if (studentProfile != null) {
                _studentProfile = studentProfile;
                _carnetController.text = _studentProfile?.carnet ?? '';
                _selectedCareerId = _studentProfile?.careerId;
                _selectedAssistanceTypeId = _studentProfile?.assistanceTypeId;

                int? usersFacultyId;
                if (_selectedCareerId != null) {
                  final allCareersForLookup =
                      await _authDataSource.getCareers();
                  final currentCareer = allCareersForLookup.firstWhereOrNull(
                    (career) => career.careerId == _selectedCareerId,
                  );
                  usersFacultyId = currentCareer?.idFaculty;
                }

                _careers =
                    await _authDataSource.getCareers(facultyId: usersFacultyId);
                _careers.sort((a, b) => a.name.compareTo(b.name));

                _admissionTrimesterController.text =
                    _studentProfile?.admissionTrimester != null
                        ? _studentProfile!.admissionTrimester!
                            .toIso8601String()
                            .split('T')
                            .first
                        : '';
              } else {
                _studentProfile = StudentProfileModel(id: currentUser.id);
                await _authDataSource.createStudentProfile(_studentProfile!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Perfil de estudiante creado automáticamente.'),
                        backgroundColor: Colors.orange),
                  );
                }
                _selectedCareerId = null;
                _selectedAssistanceTypeId = null;
                _careers = await _authDataSource.getCareers();
                _careers.sort((a, b) => a.name.compareTo(b.name));
              }
            }
          }

          if (_userProfile?.userType == 'Professor') {
            final professorProfile =
                await _authDataSource.getProfessorProfile(currentUser.id);
            if (mounted) {
              if (professorProfile == null) {
                await _authDataSource.createProfessorProfile(
                  ProfessorProfileModel(
                    id: currentUser.id,
                    departamentId: null,
                    hireDate: null,
                    isActive: true,
                  ),
                );
                final loadedProfile = await _authDataSource.getProfessorProfile(currentUser.id);
                if (mounted && loadedProfile != null) {
                  setState(() {
                    _selectedDepartmentId = loadedProfile.departamentId;
                    if (_selectedDepartmentId != null) {
                      final dept = _departments.firstWhereOrNull(
                        (d) => d.idDepartment == _selectedDepartmentId,
                      );
                      _selectedFacultyId = dept?.idFaculty;
                    }
                    _hireDateProfessorController.text = loadedProfile.hireDate != null
                        ? loadedProfile.hireDate!.toIso8601String().split('T').first
                        : '';
                    _isActiveProfessor = loadedProfile.isActive ?? true;
                  });
                }
              } else {
                setState(() {
                  _selectedDepartmentId = professorProfile.departamentId;
                  if (_selectedDepartmentId != null) {
                    final dept = _departments.firstWhereOrNull(
                      (d) => d.idDepartment == _selectedDepartmentId,
                    );
                    _selectedFacultyId = dept?.idFaculty;
                  } else {
                    _selectedFacultyId = null;
                  }
                  _hireDateProfessorController.text = professorProfile.hireDate != null
                      ? professorProfile.hireDate!.toIso8601String().split('T').first
                      : '';
                  _isActiveProfessor = professorProfile.isActive ?? true;
                });
              }
            }
          }

          if (_userProfile?.userType == 'Admin') {
            final adminProfile = await _authDataSource.getAdmin(currentUser.id);
            if (mounted) {
              setState(() {
                _adminProfile = adminProfile;
              });
            }
          }
        } else {
          String initialUserType = 'Other';
          if (currentUser.email!.endsWith('@correo.unimet.edu.ve')) {
            initialUserType = 'Student';
          } else if (currentUser.email!.endsWith('@unimet.edu.ve')) {
            initialUserType = 'Professor';
          }
          if (_userProfile?.userType == 'Admin') {
            initialUserType = 'Admin';
          }

          _userProfile = UserProfileModel(
            id: currentUser.id,
            email: currentUser.email!,
            userType: initialUserType,
          );
          try {
            await _authDataSource.createUserProfile(_userProfile!);

            if (initialUserType == 'Student') {
              await _authDataSource
                  .createStudentProfile(StudentProfileModel(id: currentUser.id));
              _selectedCareerId = null;
              _selectedAssistanceTypeId = null;
              _careers = await _authDataSource.getCareers();
              _careers.sort((a, b) => a.name.compareTo(b.name));
            }
            if (initialUserType == 'Professor') {
              await _authDataSource.createProfessorProfile(
                ProfessorProfileModel(
                  id: currentUser.id,
                  departamentId: null,
                  hireDate: null,
                  isActive: true,
                ),
              );
            
              
            }

            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
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
        userType: _userProfile!.userType ?? '',
        avatarUrl: _userProfile!.avatarUrl,
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

      if (_userProfile?.userType == 'Professor') {
        final updatedProfessorProfile = ProfessorProfileModel(
          id: _userProfile!.id,
          departamentId: _selectedDepartmentId,
          hireDate: _hireDateProfessorController.text.isNotEmpty
              ? DateTime.tryParse(_hireDateProfessorController.text)
              : null,
          isActive: _isActiveProfessor ?? true,
        );
        await _authDataSource.updateProfessorProfile(updatedProfessorProfile);
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

  Future<void> _updatePassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _passwordErrorMessage = "Por favor, completa ambos campos.";
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _passwordErrorMessage = "Las contraseñas no coinciden.";
      });
      return;
    }

    setState(() {
      _isUpdatingPassword = true;
      _passwordErrorMessage = null;
      _passwordSuccessMessage = null;
    });

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      setState(() {
        _passwordSuccessMessage = "Contraseña actualizada correctamente.";
      });

      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } on AuthException catch (e) {
      setState(() {
        _passwordErrorMessage = "Error: ${e.message}";
      });
    } catch (e) {
      setState(() {
        _passwordErrorMessage = "Error inesperado: $e";
      });
    } finally {
      setState(() {
        _isUpdatingPassword = false;
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
        final String imagePathInBucket = 'avatars/$fileName';

        final Uint8List fileBytes = await image.readAsBytes();

        await supabase.storage.from('avatars').uploadBinary(
              imagePathInBucket,
              fileBytes,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
            );

        final String publicUrl = supabase.storage
            .from('avatars')
            .getPublicUrl(imagePathInBucket);

        final updatedProfile = _userProfile!.copyWith(
          avatarUrl: publicUrl,
          userType: _userProfile!.userType ?? '',
        );
        await _authDataSource.updateUserProfile(updatedProfile);

        setState(() {
          _userProfile = updatedProfile;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avatar actualizado exitosamente!'),
              backgroundColor: Colors.green,
            ),
          );
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
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final String? currentUserType = _userProfile?.userType;
    final bool isStudent = currentUserType == 'Student';
    final bool isProfessor = currentUserType == 'Professor';
    final bool isAdmin = currentUserType == 'Admin';

    if (_isLoadingProfile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
            ),
          ],
          bottom: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.person)), // Pestaña de perfil
            Tab(icon: Icon(Icons.lock)),   // Pestaña de contraseña
          ],
        ),
        ),
        body: TabBarView(
          children: [
            // Profile Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _uploadAvatar,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        backgroundImage: (_userProfile?.avatarUrl != null && _userProfile!.avatarUrl!.isNotEmpty)
                            ? NetworkImage(_userProfile!.avatarUrl!)
                            : null,
                        child: (_userProfile?.avatarUrl == null || _userProfile!.avatarUrl!.isEmpty)
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

                  Text(
                    'Correo Electrónico:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF003087),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: TextEditingController(text: _userProfile?.email ?? 'N/A'),
                    labelText: 'Email',
                    prefixIcon: Icons.email,
                    enabled: !isAdmin,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Nombre Completo:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF003087),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _fullNameController,
                    labelText: 'Nombre Completo',
                    prefixIcon: Icons.person,
                    enabled: true,
                    maxLength: 100,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Fecha de Nacimiento:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF003087),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _birthDateController,
                    labelText: 'Fecha de Nacimiento (YYYY-MM-DD)',
                    prefixIcon: Icons.calendar_today,
                    enabled: !isAdmin,
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Género:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF003087),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _genderController.text.isNotEmpty ? _genderController.text : null,
                    decoration: InputDecoration(
                      labelText: 'Género',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                      DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                      DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                    ],
                    onChanged: !isAdmin
                        ? (String? value) {
                            setState(() {
                              _genderController.text = value ?? '';
                            });
                          }
                        : null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor selecciona un género';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  if (isAdmin && _adminProfile != null) ...[
                    const Text(
                      'Información de Administrador',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003087),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: TextEditingController(text: _adminProfile!.idAdmin),
                      labelText: 'ID Administrador',
                      prefixIcon: Icons.badge,
                      enabled: false,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: TextEditingController(
                        text: _adminProfile!.createdDate != null
                            ? _adminProfile!.createdDate!.toIso8601String().split('T').first
                            : '',
                      ),
                      labelText: 'Fecha de Creación',
                      prefixIcon: Icons.calendar_today,
                      enabled: false,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: TextEditingController(
                        text: _adminProfile!.isActive == true ? 'Activo' : 'Inactivo',
                      ),
                      labelText: 'Estado',
                      prefixIcon: Icons.verified_user,
                      enabled: false,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: TextEditingController(text: _adminProfile!.role ?? ''),
                      labelText: 'Rol',
                      prefixIcon: Icons.security,
                      enabled: false,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: TextEditingController(
                        text: _adminProfile!.inactiveSince != null
                            ? _adminProfile!.inactiveSince!.toIso8601String().split('T').first
                            : '',
                      ),
                      labelText: 'Inactivo Desde',
                      prefixIcon: Icons.event_busy,
                      enabled: false,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/create-student');
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Crear Estudiante'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/create-professor');
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Crear Profesor'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (isStudent) ...[
                    const Text(
                      'Información de Estudiante',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003087),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _carnetController,
                      labelText: 'Carnet',
                      prefixIcon: Icons.card_membership,
                      enabled: true,
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
                      enabled: true,
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (isProfessor) ...[
                    const Text(
                      'Información de Profesor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003087),
                      ),
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Facultad',
                        prefixIcon: const Icon(Icons.account_balance),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      value: _selectedFacultyId,
                      items: _faculties.map((fac) {
                        return DropdownMenuItem<int>(
                          value: fac.idFaculty,
                          child: Text(fac.name),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedFacultyId = newValue;
                          if (_selectedDepartmentId != null) {
                            final dept = _departments.firstWhereOrNull(
                              (d) => d.idDepartment == _selectedDepartmentId,
                            );
                            if (dept == null || dept.idFaculty != newValue) {
                              _selectedDepartmentId = null;
                            }
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor selecciona una facultad';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Departamento',
                        prefixIcon: const Icon(Icons.apartment),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      value: _selectedDepartmentId,
                      items: _departments
                          .where((dept) => _selectedFacultyId == null || dept.idFaculty == _selectedFacultyId)
                          .map((dept) {
                        return DropdownMenuItem<int>(
                          value: dept.idDepartment,
                          child: Text(dept.dptName),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedDepartmentId = newValue;
                          final dept = _departments.firstWhereOrNull((d) => d.idDepartment == newValue);
                          if (dept != null) {
                            _selectedFacultyId = dept.idFaculty;
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor selecciona un departamento';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: _hireDateProfessorController,
                      labelText: 'Fecha de Contratación (YYYY-MM-DD)',
                      prefixIcon: Icons.date_range,
                      readOnly: true,
                      onTap: () => _selectDate(context, _hireDateProfessorController),
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

            // Password Change Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _passwordFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Cambiar contraseña",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Nueva contraseña",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Confirmar nueva contraseña",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != _newPasswordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_passwordErrorMessage != null)
                      Text(
                        _passwordErrorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    if (_passwordSuccessMessage != null)
                      Text(
                        _passwordSuccessMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUpdatingPassword ? null : _updatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003087),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isUpdatingPassword
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Actualizar contraseña",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}