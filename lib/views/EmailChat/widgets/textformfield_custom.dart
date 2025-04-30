import 'package:flutter/material.dart';

Widget buildTextFormField(
    String label, TextEditingController controller, int lines) {
  return TextFormField(
    controller: controller,
    style: TextStyle(
      fontSize: 12,
    ),
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: Colors.blue,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: Colors.blue,
          width: 1.0,
        ),
      ),
    ),
    maxLines: lines,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter information';
      }
      return null;
    },
  );
}