import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/internal_constants/typedef.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/styles_consts.dart';
import '../../../note/domain/entities/note.dart';
import '../../../note/presentation/controllers/note_controller.dart';
import '../../../note/presentation/screens/notes_list_screen.dart';
import '../../../user/presentation/widgets/user_avatar.dart';
import '../../domain/entities/session_member.dart';
import '../../domain/entities/sub/session_member_role.dart';
import '../controllers/session_controller.dart';

enum SessionPopupOption { end }

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  final _noteTitleController = TextEditingController();
  final _noteContentController = TextEditingController();
  Note? _note;

  @override
  void initState() {
    super.initState();

    final noteId = ref.read(sessionControllerProvider).session?.noteId ?? '';
    ref.read(noteControllerProvider.notifier).fetchNoteStream(noteId).listen((
      note,
    ) {
      _note = note;
      _noteTitleController.text = note?.title ?? _noteTitleController.text;
      _noteContentController.text =
          note?.content ?? _noteContentController.text;
    });
  }

  @override
  void dispose() {
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
        actions: [
          PopupMenuButton(
            onSelected: (option) async {
              final controller = ref.read(sessionControllerProvider.notifier);
              switch (option) {
                case SessionPopupOption.end:
                  await controller.endSession();
                  context.pop(const NotesListScreen());
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: SessionPopupOption.end,
                child: Text('End Session'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Code:',
                    style: const TextStyle(
                      color: Color(0xE2FFFFFF),
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      const TextSpan(text: '    '),
                      TextSpan(
                        text: session?.sessionCode ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    // TODO: implement copy to clipboard
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          StreamBuilder<RowList>(
            stream:
                ref
                        .read(sessionControllerProvider.notifier)
                        .fetchMembersOfSession()
                    as Stream<RowList>,
                    
            builder: (context, snapshot) {
              final members =
                  snapshot.data?.map(SessionMember.fromMap).toSet() ?? {};
              final fakeMembers = List.generate(
                8,
                (_) => SessionMember(
                  sessionId: '',
                  memberId: '',
                  role: SessionMemberRole.member,
                ),
              );
              final enabledFake =
                  snapshot.connectionState == ConnectionState.waiting;


              return SizedBox(
                height: 130,
                child: Skeletonizer(
                  effect: StylesConsts.shimmerEffect,
                  enabled: enabledFake,
                  child: ListView.separated(
                    itemCount: enabledFake
                        ? fakeMembers.length
                        : members.length,
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final member = enabledFake
                          ? fakeMembers[index]
                          : members.elementAt(index);

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 10,
                        children: [
                          const PlaceholderAvatar(),
                          Text(member.role.name),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          TextFormField(
            controller: _noteTitleController,

            style: TextStyle(color: Colors.white.withAlpha(200)),
            cursorColor: const Color(0x809CDEBC),
            decoration: const InputDecoration(hintText: 'Enter Text Here...'),
            onChanged: (title) {
              if (_note == null) return;
              noteController.updateNote(_note!.copyWith(title: title));
            },
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 300,
            child: TextFormField(
              controller: _noteContentController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(color: Colors.white.withAlpha(200)),
              cursorColor: const Color(0x809CDEBC),
              decoration: const InputDecoration(hintText: 'Enter Text Here...'),
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
