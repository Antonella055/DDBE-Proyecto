import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool enabled; 
  final bool readOnly; 
  final VoidCallback? onTap; 
  final String? Function(String?)? validator; 
  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.keyboardType,
    this.maxLength,
    this.obscureText = false,
    this.suffixIcon,
    this.enabled = true, 
    this.readOnly = false, 
    this.onTap, 
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2.0),
        ),
      ),
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscureText,
      enabled: enabled, 
      readOnly: readOnly, 
      onTap: onTap, 
      validator: validator,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxLength),
      ],
      style: TextStyle(
        fontSize: 16.0,
        color: enabled ? Colors.black87 : Colors.grey[700],
      ),
      cursorColor: Theme.of(context).primaryColor,
    );
  }
}