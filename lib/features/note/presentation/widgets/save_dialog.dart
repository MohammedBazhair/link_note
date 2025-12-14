import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';

class SaveDialog extends StatelessWidget {
  const SaveDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(30),
      content: const Row(
        spacing: 10,
        children: [
          Icon(Icons.info_outline_rounded),
          Text('Do you want to save?'),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => context.pop(true),
          child: const Text('Yes'),
        ),
        TextButton(
          onPressed: () => context.pop(false),
          child: const Text('No'),
        ),
      ],
    );
  }
}
