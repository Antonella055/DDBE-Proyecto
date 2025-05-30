import 'package:ayudantia_software/features/auth/data/datasources/auth_service.dart';
import 'package:flutter/material.dart';

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

