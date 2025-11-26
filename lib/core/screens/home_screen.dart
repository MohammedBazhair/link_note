import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link_note/features/auth/services/auth.dart';
import 'package:link_note/features/note/domain/entities/note.dart';
import 'package:link_note/features/note/presentation/screens/notes_list_screen.dart';
import 'package:link_note/features/note/services/notes_service.dart';
import 'package:link_note/features/qr_code/presentation/screens/generate_qr_code_screen.dart';
import 'package:link_note/features/qr_code/presentation/screens/scanner_qr_code_screen.dart';
import 'package:link_note/features/user/presentation/widgets/user_profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final formKey = GlobalKey<FormState>();
  final noteContentController = TextEditingController();

  Future<void> onGenerateQrSubmit() async {
    final isFormValid = formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    final noteContent = noteContentController.text;
    await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => GenerateQrCodeScreen(data: noteContent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LinkNote"),
        actions: [
          IconButton.filled(
            onPressed: () async {
              await AuthService().signIn(
                email: "me@gm.com",
                password: '123456',
              );
              setState(() {});
            },
            icon: Icon(Icons.account_circle),
          ),
          IconButton.filled(
            onPressed: () async {
              final note = Note(
                title: 'Meeting Reminder',
                content:
                    'Team meeting tomorrow at 10 AM. Prepare project updates',
              );
              await NotesService().create(note);
            },
            icon: Icon(Icons.add_link_rounded),
          ),
          IconButton.filled(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoModalPopupRoute(
                  builder: (context) => NotesListScreen(),
                ),
              );
            },
            icon: Icon(Icons.notes_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            UserProfile(),
            Expanded(
              child: ListView(
                children: [
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: noteContentController,
                      maxLines: 14,
                      style: TextStyle(color: Colors.white.withAlpha(200)),
                      cursorColor: const Color(0x809CDEBC),
                      decoration: InputDecoration(
                        hintText: "Enter Text Here...",
                      ),
                      onFieldSubmitted: (_) => onGenerateQrSubmit(),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "Field Can't be Empty";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                spacing: 20,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Color(0xFF00C2CC),
                        ),
                      ),
                      onPressed: onGenerateQrSubmit,
                      child: Text("Generate QR"),
                    ),
                  ),

                  if (!Platform.isWindows)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final scannedNote = await Navigator.of(context)
                              .push<String>(
                                MaterialPageRoute(
                                  builder: (_) => ScannerQrCodeScreen(),
                                ),
                              );
                          if (scannedNote?.isEmpty ?? true) return;
                          noteContentController.text = scannedNote ?? "";
                        },
                        child: Text("Scan QR"),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
