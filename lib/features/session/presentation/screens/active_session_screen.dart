import 'package:flutter/material.dart';

import '../widgets/active_session_members.dart';
import '../widgets/session_code_card.dart';
import '../widgets/session_note.dart';
import '../widgets/session_popup_menu.dart';

class ActiveSessionScreen extends StatelessWidget {
  const ActiveSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الجلسة الحالية'),
        actions: const [SessionPopupMenu()],
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SessionCodeCard(),
            SizedBox(height: 35),
            Text(
              'الأعضاء',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ActiveSessionMembers(),
            SizedBox(height: 20),
            Divider(thickness: 0.5),

            SizedBox(height: 20),
            Text(
              'الملاحظة المشتركة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Expanded(child: SessionNoteEditor()),
          ],
        ),
      ),
    );
  }
}
