import 'package:flutter/material.dart';

class SnackBarActionModel {
  const SnackBarActionModel({required this.label, required this.onPressed});
  
  final String label;
  final VoidCallback onPressed;
}
