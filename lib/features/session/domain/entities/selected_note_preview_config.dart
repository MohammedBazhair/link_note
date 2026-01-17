import 'package:flutter/material.dart';
import '../../../note/domain/entities/note.dart';

class SelectedNotePreviewConfig {
  SelectedNotePreviewConfig({
    required this.note,
    required this.onButtonPressed,
    required this.onCardPressed,
    required this.statusLabel,
    required this.textButtonLabel,
    required this.textButtonIcon,
  });

  factory SelectedNotePreviewConfig.fake() {
    return SelectedNotePreviewConfig(
      note: Note.fake(),
      onButtonPressed: () {},
      onCardPressed: () {},
      statusLabel: 'hrjhkjgkjgkjg',
      textButtonLabel: 'textButtonLabel',
      textButtonIcon: Icons.edit,
    );
  }

  final Note note;

  final VoidCallback onButtonPressed;
  final VoidCallback onCardPressed;
  final String statusLabel;
  final String textButtonLabel;
  final IconData textButtonIcon;
}
