import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link_note/core/constants/colors/colors.dart';

class CustomFullNameField extends StatelessWidget {
  const CustomFullNameField({super.key, required this.nameController});

  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: nameController,
      cursorColor: DarkColors.cursor,
      cursorRadius: Radius.circular(20),
      cursorWidth: 1.3,
      textInputAction: TextInputAction.next,

      decoration: InputDecoration(
        hintText: "Enter your name",
        prefixIcon: Padding(
          padding: EdgeInsetsDirectional.only(start: 15.0),
          child: const Icon(Icons.person_outline),
        ),
      ),

      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\u0621-\u064A ]')),
      ],

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Name is required';
        }

        if (value.trim().length < 3) {
          return 'Name must be at least 3 characters';
        }

        return null;
      },
    );
  }
}
