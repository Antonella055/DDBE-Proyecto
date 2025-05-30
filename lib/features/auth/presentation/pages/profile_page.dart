import 'package:ayudantia_software/features/auth/data/datasources/auth_service.dart';
import 'package:flutter/material.dart';


class ProfileModel {
  final formKey = GlobalKey<FormState>();

 
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
  final authService= AuthService();

  void logout() async{
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final currentEmail=authService.getCurrentUserEmail();

    return Scaffold(
      appBar: AppBar(
        title:  const Text("Profile"),
        actions:[
          //logout button
          IconButton(
            onPressed:logout,
            icon:const Icon(Icons.abc_rounded),
            )
        ],
      ),
      body: Center(
        child: Text(currentEmail.toString()),
      
      ),
    );


  }
}