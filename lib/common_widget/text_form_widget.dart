import 'package:flutter/material.dart';

class MyTextFromField extends StatelessWidget {
  TextEditingController controller = TextEditingController();
  final String hintText;
  final Icon icon;
  final String errorMessage;
  final bool obscureText;
  final String? Function(String?)? validator;

  MyTextFromField({
    required this.controller,
    required String this.hintText,
    required this.icon,
    required this.errorMessage,
    required this.obscureText,  this.validator
  });

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(15),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        obscureText: obscureText,
        validator: validator,

        controller: controller,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            prefixIcon: icon),
      ),
    );
  }
}
