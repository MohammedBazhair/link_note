import 'package:flutter/material.dart';
import 'package:link_note/core/presentation/screens/home_screen.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 30,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      },
      icon: Icon(Icons.home),
    );
  }
}
