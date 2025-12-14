import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentFormField extends ConsumerWidget {
  const ContentFormField({
    super.key,
    required this.controller,
    this.onChanged,
    this.readOnly = false,
  });
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context,ref) {
    return TextFormField(
      controller: controller,
      maxLines: null,
      expands: true,
readOnly: readOnly,
      textAlignVertical: TextAlignVertical.top,
      style: TextStyle(color: Colors.white.withAlpha(200)),
      cursorColor: const Color(0x809CDEBC),
      decoration: const InputDecoration(hintText: 'Enter Text Here...'),
      onChanged: onChanged,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return "Field Can't be Empty";
        }
        return null;
      },
    );
  }
}
