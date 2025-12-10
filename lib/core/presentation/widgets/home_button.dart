import 'package:flutter/material.dart';
import '../../../features/note/presentation/screens/notes_list_screen.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 30,
      hoverColor: Colors.transparent,

      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotesListScreen()),
        );
      },
      icon: const Icon(Icons.home),
    );
  }
}
