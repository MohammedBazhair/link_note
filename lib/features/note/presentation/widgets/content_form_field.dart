import 'package:flutter/material.dart';

class ContentFormField extends StatelessWidget {
  const ContentFormField({super.key, required this.controller, this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: null,
      expands: true,
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
