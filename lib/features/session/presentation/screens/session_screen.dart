import 'package:flutter/material.dart';

import '../widgets/session_code_card.dart';
import '../widgets/session_members_list.dart';
import '../widgets/session_note.dart';
import '../widgets/session_popup_menu.dart';

class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

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
          spacing: 20,
          children: [
            SessionCodeCard(),
            SessionMembersList(),

            Expanded(child: SessionNote()),
          ],
        ),
      ),
    );
  }
}
