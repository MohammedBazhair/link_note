import 'package:flutter/material.dart';

class NothingNoteWidget extends StatelessWidget {
  const NothingNoteWidget({super.key,});



  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No notes available.\nTap the + button to add a new note.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}
