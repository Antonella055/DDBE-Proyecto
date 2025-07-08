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
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
  bool? _isActiveProfessor;
  bool _isLoadingProfile = true;
  bool _isUpdatingProfile = false;
  bool _isUpdatingPassword = false;
  String? _passwordErrorMessage;
  String? _passwordSuccessMessage;
  bool _showPasswordSection = false;
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
    Widget build(BuildContext context) {
      const String backgroundUrl = 'https://lbxkcilriktsmfiruvfj.supabase.co/storage/v1/object/public/backgrounds/backgrounds/profile_page.jpg';
      
      if (_isLoadingProfile) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi Perfil'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _signOut,
              ),
            ],
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      final isStudent = _userProfile?.userType == 'Student';
      final isProfessor = _userProfile?.userType == 'Professor';
      final isAdmin = _userProfile?.userType == 'Admin';

      return Scaffold(
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(backgroundUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                       Card(
                          elevation: 5,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(
                              minHeight: 400, // Altura mínima consistente
                            ),
                            padding: const EdgeInsets.all(25),
                            child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: _uploadAvatar,
                                    child: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 60,
                                          backgroundColor: Colors.grey[200],
                                          backgroundImage: _userProfile?.avatarUrl != null
                                              ? NetworkImage(_userProfile!.avatarUrl!)
                                              : null,
                                          child: _userProfile?.avatarUrl == null
                                              ? const Icon(Icons.person, size: 60)
                                              : null,
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                              color: Colors.blue,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _userProfile?.fullName ?? 'Usuario',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          _userProfile?.email ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Chip(
                                          label: Text(
                                            isStudent
                                                ? 'Estudiante'
                                                : isProfessor
                                                    ? 'Profesor'
                                                    : 'Administrador',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          backgroundColor: const Color(0xFF003087),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              LayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.maxWidth > 800) {
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: _buildPersonalInfoSection(),
                                        ),
                                        const SizedBox(width: 30),
                                        Expanded(
                                          flex: 1,
                                          child: _buildRoleSpecificSection(),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      children: [
                                        _buildPersonalInfoSection(),
                                        const SizedBox(height: 30),
                                        _buildRoleSpecificSection(),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 30),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isUpdatingProfile ? null : _updateUserProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF003087),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: _isUpdatingProfile
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text(
                                          'GUARDAR CAMBIOS',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tarjeta de cambio de contraseña modificada
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.lock, 
                                  color: const Color(0xFF003087),
                                ),
                                title: Text(
                                  'Cambiar Contraseña',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF003087),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    _showPasswordSection
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: const Color(0xFF003087),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showPasswordSection = !_showPasswordSection;
                                    });
                                  },
                                ),
                              ),
                              
                              if (_showPasswordSection) ...[
                                const Divider(),
                                const SizedBox(height: 20),
                                if (isAdmin)
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: Text(
                                      'Los administradores no pueden cambiar su contraseña desde esta sección',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                if (!isAdmin) _buildPasswordSection(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildPasswordSection() {
      return Form(
        key: _passwordFormKey,
        child: Column(
          children: [
            _buildPasswordField('Nueva Contraseña', _newPasswordController),
            const SizedBox(height: 15),
            _buildPasswordField('Confirmar Contraseña', _confirmPasswordController),
            const SizedBox(height: 15),
            if (_passwordErrorMessage != null)
              Text(
                _passwordErrorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            if (_passwordSuccessMessage != null)
              Text(
                _passwordSuccessMessage!,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUpdatingPassword ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003087),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isUpdatingPassword
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text(
                        'ACTUALIZAR CONTRASEÑA',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      );
    }


  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Información Personal',
      children: [
        _buildTextField('Nombre Completo', _fullNameController),
        const SizedBox(height: 15),
        _buildDateField('Fecha de Nacimiento', _birthDateController),
        const SizedBox(height: 15),
        _buildDropdown(
          'Género',
          _genderController,
          ['Femenino', 'Masculino', 'Otro'],
        ),
      ],
    );
  }

  Widget _buildRoleSpecificSection() {
    if (_userProfile?.userType == 'Student') {
      return _buildStudentSection();
    } else if (_userProfile?.userType == 'Professor') {
      return _buildProfessorSection();
    } else if (_userProfile?.userType == 'Admin') {
      return _buildAdminSection();
    }
    return Container();
  }

  Widget _buildStudentSection() {
    return _buildSection(
      title: 'Información Académica',
      children: [
        _buildTextField('Carnet', _carnetController),
        const SizedBox(height: 15),
        DropdownButtonFormField<int>(
          value: _selectedCareerId,
          decoration: InputDecoration(
            labelText: 'Carrera',
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: const Icon(Icons.school),
          ),
          items: _careers.map((career) {
            return DropdownMenuItem<int>(
              value: career.careerId,
              child: Text(
                career.name,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (int? newValue) {
            setState(() => _selectedCareerId = newValue);
          },
        ),
        const SizedBox(height: 15),
        DropdownButtonFormField<int>(
          value: _selectedAssistanceTypeId,
          decoration: InputDecoration(
            labelText: 'Tipo de Asistencia',
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: const Icon(Icons.help_outline),
          ),
          items: _assistanceTypes.map((type) {
            return DropdownMenuItem<int>(
              value: type.assistanceTypeId,
              child: Text(
                type.type,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (int? newValue) {
            setState(() => _selectedAssistanceTypeId = newValue);
          },
        ),
        const SizedBox(height: 15),
        _buildDateField('Trimestre de Admisión', _admissionTrimesterController),
      ],
    );
  }

  Widget _buildProfessorSection() {
  return _buildSection(
    title: 'Información Profesional',
    children: [
      DropdownButtonFormField<int>(
        value: _selectedFacultyId,
        decoration: InputDecoration(
          labelText: 'Facultad',
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: const Icon(Icons.account_balance),
        ),
        items: _faculties.map((faculty) {
          return DropdownMenuItem<int>(
            value: faculty.idFaculty,
            child: Text(
              faculty.name,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }).toList(),
        onChanged: (int? newValue) {
          setState(() {
            _selectedFacultyId = newValue;
            _selectedDepartmentId = null;
          });
        },
      ),
      const SizedBox(height: 15),
      DropdownButtonFormField<int>(
        value: _selectedDepartmentId,
        decoration: InputDecoration(
          labelText: 'Departamento',
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: const Icon(Icons.apartment),
        ),
        items: _departments
            .where((dept) => _selectedFacultyId == null || dept.idFaculty == _selectedFacultyId)
            .map((dept) {
          return DropdownMenuItem<int>(
            value: dept.idDepartment,
            child: Text(
              dept.dptName,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }).toList(),
        onChanged: (int? newValue) {
          setState(() => _selectedDepartmentId = newValue);
        },
      ),
      const SizedBox(height: 15),
      _buildDateField('Fecha de Contratación', _hireDateProfessorController),
      const SizedBox(height: 15),
      // Estado del profesor (no editable)
      IgnorePointer(
        ignoring: true,
        child: SwitchListTile(
          title: const Text(
            'Profesor Activo',
            style: TextStyle(fontSize: 16),
          ),
          value: _isActiveProfessor ?? true,
          onChanged: null, // Deshabilitado
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ],
  );
}

Widget _buildAdminSection() {
  return _buildSection(
    title: 'Información Administrativa',
    children: [
      _buildTextField('ID', TextEditingController(text: _adminProfile?.idAdmin ?? '')),
      const SizedBox(height: 15),
      _buildDateField('Fecha de Creación', 
          TextEditingController(text: _adminProfile?.createdDate?.toIso8601String().split('T').first ?? '')),
      const SizedBox(height: 15),
      // Estado del admin (no editable)
      IgnorePointer(
        ignoring: true,
        child: _buildTextField(
          'Estado', 
          TextEditingController(text: _adminProfile?.isActive == true ? 'Activo' : 'Inactivo')
        ),
      ),
      const SizedBox(height: 15),
      _buildTextField('Rol', TextEditingController(text: _adminProfile?.role ?? '')),
      const SizedBox(height: 15),
      _buildDateField('Inactivo Desde', 
          TextEditingController(text: _adminProfile?.inactiveSince?.toIso8601String().split('T').first ?? '')),
      const SizedBox(height: 25),
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/create-student'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003087),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Crear Estudiante',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/create-professor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003087),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Crear Profesor',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
  

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF003087),
          ),
        ),
        const Divider(thickness: 1),
        const SizedBox(height: 15),
        ...children,
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDate(context, controller),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: const Icon(Icons.calendar_today),
      ),
    );
  }

  Widget _buildDropdown(String label, TextEditingController controller, List<String> options) {
    return DropdownButtonFormField<String>(
      value: controller.text.isNotEmpty ? controller.text : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(
            option,
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => controller.text = value ?? ''),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: const Icon(Icons.lock),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es requerido';
        }
        if (value.length < 6) {
          return 'Mínimo 6 caracteres';
        }
        return null;
      },
    );
  }


}