import 'package:flutter/material.dart';

extension ShowSnackbar on BuildContext {
  void showSnakbar(String msg) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(msg)));
  }
}
