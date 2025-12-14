import 'package:flutter/material.dart';

class TitleFormField extends StatelessWidget {
  const TitleFormField({super.key, required this.controller, this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 2,
      minLines: 1,
      style: TextStyle(color: Colors.white.withAlpha(200)),
      cursorColor: const Color(0x809CDEBC),
      decoration: const InputDecoration(hintText: 'Title...'),
      onChanged: onChanged,
    );
  }
}
