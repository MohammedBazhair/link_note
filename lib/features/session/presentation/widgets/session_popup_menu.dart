import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../note/presentation/screens/notes_list_screen.dart';
import '../controllers/session_controller.dart';

enum SessionPopupOption { end }

class SessionPopupMenu extends ConsumerWidget {
  const SessionPopupMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<SessionPopupOption>(
      onSelected: (option) async {
        final controller = ref.read(sessionControllerProvider.notifier);
        switch (option) {
          case SessionPopupOption.end:
            await controller.endSession();
            context.pop(const NotesListScreen());
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: SessionPopupOption.end,
          child: Text('End Session'),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}
