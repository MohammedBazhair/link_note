import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link_note/core/constants/colors/colors.dart';

class CustomEmailField extends StatelessWidget {
  const CustomEmailField(this.controller, {super.key});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofillHints: [AutofillHints.email],
      keyboardType: TextInputType.emailAddress,
      cursorColor: DarkColors.cursor,
      cursorRadius: Radius.circular(20),
      cursorWidth: 1.3,
      textInputAction: TextInputAction.next,

      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
      ],
      decoration: InputDecoration(
        hintText: "Enter your email",
        prefixIcon: Padding(
          padding: EdgeInsetsDirectional.only(start: 15.0),
          child: const Icon(Icons.email_outlined),
        ),
      ),

    validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }

        // Regular Email Pattern
        final emailRegExp = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        );

        if (!emailRegExp.hasMatch(value)) {
          return 'Enter a valid email address';
        }

        return null;

    },
    );
  }
}
