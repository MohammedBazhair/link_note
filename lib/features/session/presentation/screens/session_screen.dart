import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../note/domain/entities/note.dart';
import '../../../note/presentation/controllers/note_controller.dart';
import '../../../note/presentation/widgets/content_form_field.dart';
import '../../../note/presentation/widgets/title_form_field.dart';
import '../controllers/session_controller.dart';
import '../widgets/session_code_card.dart';
import '../widgets/session_members_list.dart';
import '../widgets/session_popup_menu.dart';

enum SessionPopupOption { end }

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  late final StreamSubscription _noteSubscription;
  final _noteTitleController = TextEditingController();
  final _noteContentController = TextEditingController();
  Note? _note;

  @override
  void initState() {
    super.initState();
    final noteId = ref.read(sessionControllerProvider).session?.noteId ?? '';

    _noteSubscription = ref
        .read(noteControllerProvider.notifier)
        .fetchNoteStream(noteId)
        .listen((note) {
          _note = note;
          _noteTitleController.text = note?.title ?? _noteTitleController.text;
          _noteContentController.text =
              note?.content ?? _noteContentController.text;
        });
  }

  @override
  void dispose() {
    _noteSubscription.cancel();
    _noteTitleController.dispose();
    _noteContentController.dispose();
    super.dispose();
  }

  NoteController get noteController =>
      ref.read(noteControllerProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider).session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Title'),
        actions: const [SessionPopupMenu()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SessionCodeCard(session?.sessionCode),

          const SizedBox(height: 30),

          SessionMembersList(
            membersStream: ref
                .read(sessionControllerProvider.notifier)
                .fetchMembersOfSession(),
          ),

          const SizedBox(height: 24),

          TitleFormField(
            controller: _noteTitleController,
            onChanged: (title) {
              if (_note == null) return;
              noteController.updateNote(_note!.copyWith(title: title));
            },
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 300,
            child: ContentFormField(
              controller: _noteContentController,
              onChanged: (content) {
                if (_note == null) return;
                noteController.updateNote(_note!.copyWith(content: content));
              },
            ),
          ),
        ],
      ),
    );
  }
}
