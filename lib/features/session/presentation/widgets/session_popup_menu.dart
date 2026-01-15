import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../note/domain/entities/note.dart';
import '../../../note/presentation/widgets/editor_form.dart';
import '../../../qr_code/presentation/screens/generate_qr_code_screen.dart';
import '../../../qr_code/presentation/screens/scanner_qr_code_screen.dart';
import '../../domain/entities/session_menu_action.dart';
import '../controllers/session_controller.dart';

class SessionPopupMenu extends ConsumerWidget {
  const SessionPopupMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(sessionControllerProvider.notifier);

    final isHost = ref.watch(
      sessionControllerProvider.select((s) => s.currentMember?.isHost ?? false),
    );

    return PopupMenuButton<SessionMenuAction>(
      icon: const Icon(Icons.more_vert),
      onSelected: (action) async {
        switch (action) {
          case SessionMenuAction.end:
            await controller.endSession();
          case SessionMenuAction.leave:
            await controller.leaveSession();

          case SessionMenuAction.qrScanner:
            final data = await context.pushTo<String?>(
              const ScannerQrCodeScreen(),
            );
            if (data == null) return;
            final note = Note.fromJson(data);
            ref.read(editorFormProvider).initForm(note);

          case SessionMenuAction.qrGenearator:
            final note = ref.read(editorFormProvider).note;
            await context.pushTo(
              GenerateQrCodeScreen(data: note.toJson() ),
            );
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: SessionMenuAction.qrGenearator,
          child: Text('توليد رمز QR'),
        ),
        if (isHost)
          PopupMenuItem(
            value: SessionMenuAction.end,
            enabled: isHost,
            child: const Text('إنهاء الجلسة'),
          ),
        const PopupMenuItem(
          value: SessionMenuAction.leave,
          child: Text('مغادرة الجلسة'),
        ),
      ],
    );
  }
}
