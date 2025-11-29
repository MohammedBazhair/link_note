import 'dart:io';
import 'package:flutter/material.dart';
import 'package:link_note/core/constants/colors/colors.dart';
import 'package:link_note/core/presentation/widgets/custom_drawer.dart';
import 'package:link_note/features/qr_code/presentation/screens/generate_qr_code_screen.dart';
import 'package:link_note/features/qr_code/presentation/screens/scanner_qr_code_screen.dart';

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
      drawer: CustomDrawer(),
      appBar: AppBar(title: Text("LinkNote")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DarkColors.primary,
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
