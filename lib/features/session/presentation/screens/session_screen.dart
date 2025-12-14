import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../note/domain/entities/note.dart';
import '../../../note/presentation/controllers/note_controller.dart';
import '../../../note/presentation/widgets/content_form_field.dart';
import '../../../note/presentation/widgets/title_form_field.dart';
import '../../domain/entities/sub/session_member_role.dart';
import '../controllers/session_controller.dart';
import '../widgets/session_code_card.dart';
import '../widgets/session_members_list.dart';
import '../widgets/session_popup_menu.dart';

final noteSessionProvider = StateProvider<Note?>((ref) => null);

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  late final StreamSubscription _noteSubscription;
  final _noteTitleController = TextEditingController();
  final _noteContentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final noteId = ref.read(sessionControllerProvider).session?.noteId ?? '';

    _noteSubscription = ref
        .read(noteControllerProvider.notifier)
        .fetchSingleNoteStream(noteId)
        .listen((note) {
          ref.read(noteSessionProvider.notifier).state = note;
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

  Note? get currentNote => ref.read(noteSessionProvider);

  NoteController get noteController =>
      ref.read(noteControllerProvider.notifier);

  bool get canEdit =>
      ref.read(sessionControllerProvider).currentMember?.role ==
      SessionMemberRole.host;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider).session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Title'),
        actions: const [SessionPopupMenu()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SessionCodeCard(session?.sessionCode),

            const SizedBox(height: 30),

            SessionMembersList(
              membersStream: ref
                  .read(sessionControllerProvider.notifier)
                  .fetchMembersOfSession(),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TitleFormField(
                      controller: _noteTitleController,
                      readOnly: canEdit,
                      onChanged: (title) {
                        if (currentNote == null) return;
                        noteController.updateNote(
                          currentNote!.copyWith(title: title),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 200,
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ContentFormField(
                        controller: _noteContentController,
                        readOnly: canEdit,
                        onChanged: (content) {
                          if (currentNote == null) return;
                          noteController.updateNote(
                            currentNote!.copyWith(content: content),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
