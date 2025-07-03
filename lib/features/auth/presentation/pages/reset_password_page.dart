import 'package:ayudantia_software/features/auth/presentation/Controllers/password_reset_controller.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordPage extends StatefulWidget {
  final bool isWeb;
  final String? token;

  const ResetPasswordPage({
    Key? key,
    required this.isWeb,
    this.token,
  }) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _controller = PasswordResetController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    if (widget.token != null) {
      setState(() => _isLoading = true);
      try {
        final response = await Supabase.instance.client.auth.verifyOTP(
          token: widget.token!,
          type: OtpType.recovery,
        );
        if (response.session == null) {
          setState(() => _errorMessage = 'Token inválido o expirado');
        }
      } catch (e) {
        setState(() => _errorMessage = 'Error verificando el token: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restablecer Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _success
            ? _buildSuccessUI()
            : _errorMessage != null
                ? _buildErrorUI()
                : _buildResetForm(),
      ),
    );
  }

  Widget _buildResetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Crea una nueva contraseña',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _newPasswordController,
          decoration: const InputDecoration(
            labelText: 'Nueva Contraseña',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          decoration: const InputDecoration(
            labelText: 'Confirmar Contraseña',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _handleResetPassword,
                child: const Text('Restablecer Contraseña'),
              ),
      ],
    );
  }

  Widget _buildSuccessUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 20),
        const Text(
          '¡Contraseña actualizada con éxito!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text('Volver al inicio de sesión'),
        ),
      ],
    );
  }

  Widget _buildErrorUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, color: Colors.red, size: 80),
        const SizedBox(height: 20),
        Text(
          _errorMessage!,
          style: const TextStyle(fontSize: 18, color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Volver'),
        ),
      ],
    );
  }

  Future<void> _handleResetPassword() async {
    // Validar contraseñas
    final validationError = _controller.validatePasswords(
      _newPasswordController.text,
      _confirmPasswordController.text,
    );
    
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Actualizar contraseña
      final error = await _controller.updatePassword(_newPasswordController.text);
      
      if (error != null) {
        setState(() => _errorMessage = error);
      } else {
        setState(() => _success = true);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error inesperado: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}