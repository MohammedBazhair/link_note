import 'package:flutter/material.dart';

class NothingNoteWidget extends StatelessWidget {
  const NothingNoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Text(
          'لاتوجد اي ملاحظات. \n قم بإنشاء ملاحظة جديدة بالضغط على زر الإضافة.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, height: 1.8),
        ),
      ),
    );
  }
}
