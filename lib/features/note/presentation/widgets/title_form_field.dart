import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class TitleFormField extends ConsumerWidget {
  const TitleFormField({
    super.key,
    required this.controller,
    this.onChanged,
    this.readOnly = false,
  });
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context, ref) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: 2,
      minLines: 1,
      style: TextStyle(color: Colors.white.withAlpha(200)),
      cursorColor: const Color(0x809CDEBC),
      decoration: const InputDecoration(hintText: 'Title...'),
      onChanged: onChanged,
    );
  }
}
