import 'package:flutter/material.dart';
import '../../../note/domain/entities/note.dart';

class SelectedNoteParams {
  SelectedNoteParams({
    required this.note,
    required this.onButtonPressed,
    required this.onCardPressd,
    required this.labelOnStack,
    required this.textButtonLabel,
    required this.textButtonIcon,
  });

  factory SelectedNoteParams.fake() {
    return SelectedNoteParams(
      note: Note.fake(),
      onButtonPressed: (){},
      onCardPressd: () {},
      labelOnStack:'hrjhkjgkjgkjg',
      textButtonLabel: 'textButtonLabel',
      textButtonIcon: Icons.edit,
    );
  }

  final Note note;

  final VoidCallback onButtonPressed;
  final VoidCallback onCardPressd;
  final String labelOnStack;
  final String textButtonLabel;
  final IconData textButtonIcon;
}
