import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/chat_providers.dart';

class FormLocalName extends StatelessWidget {
  const FormLocalName({super.key, required this.nameController});

  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم الجهاز',
            hintText: 'اسم الجهاز',
          ),
        ),
        const SizedBox(height: 16),
        Consumer(
          builder: (context, ref, child) {
            return ElevatedButton(
              onPressed: () {
                final controller = ref.read(connectionManagerProvider);
                controller.updateLocalName(nameController.text);
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            );
          },
        ),
      ],
    );
  }
}
