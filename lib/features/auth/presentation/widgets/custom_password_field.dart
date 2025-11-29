import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link_note/core/constants/colors/colors.dart';

class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController? originalController;
  final String hintText;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    this.originalController,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool obscure = true;

  String? get confirmPassword => widget.originalController?.text;
  bool get isConfirmField => widget.originalController != null;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autofillHints: !isConfirmField ? [AutofillHints.password]:null,

      obscureText: obscure,
      cursorColor: DarkColors.cursor,
      cursorRadius: Radius.circular(20),
      cursorWidth: 1.3,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        FocusScope.of(context).nextFocus();
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'[a-zA-Z0-9!@#\$%^&*()_\-+=.?]'),
        ),
      ],
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Padding(
          padding: EdgeInsetsDirectional.only(start: 15.0),
          child: Icon(Icons.lock_outline),
        ),
        suffixIcon: IconButton(
          padding: EdgeInsetsDirectional.only(end: 15.0),

          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => obscure = !obscure),
        ),
      ),

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Password is required';
        }

        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }

        if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
          return 'Password must contain at least one letter';
        }

        if (confirmPassword != null && value != confirmPassword) {
          return 'Passwords do not match';
        }

        return null;
      },
    );
  }
}
