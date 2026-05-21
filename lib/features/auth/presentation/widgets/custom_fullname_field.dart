import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/field_label.dart';

class CustomFullNameField extends StatelessWidget {
  const CustomFullNameField({super.key, required this.nameController});

  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(text: 'الاسم الكامل'),

        TextFormField(
          controller: nameController,
          cursorRadius: const Radius.circular(20),
          cursorWidth: 1.3,
          textInputAction: TextInputAction.next,

          decoration: const InputDecoration(
            hintText: 'أدخل اسمك الكامل',
            prefixIcon: Padding(
              padding: EdgeInsetsDirectional.only(start: 15.0),
              child: Icon(Icons.person_outline),
            ),
          ),

          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-Z0-9\u0621-\u064A ]'),
            ),
          ],

          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'الاسم الكامل مطلوب';
            }

            if (value.trim().length < 3) {
              return 'الاسم الكامل يجب أن يكون على الأقل 3 أحرفس';
            }

            return null;
          },
        ),
      ],
    );
  }
}
