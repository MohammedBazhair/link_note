import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/conditional_builder.dart';
import '../../../note/presentation/controllers/note_providers.dart';
import '../../domain/entities/selected_note_preview_config.dart';
import '../../domain/entities/session_mode.dart';
import '../../domain/entities/sub/session_status.dart';
import '../../handle_session_states.dart';
import '../../injection.dart';
import '../controllers/session_providers.dart';
import '../widgets/create_session_form.dart';
import '../widgets/join_session_form.dart';
import '../widgets/selected_note_preview.dart';
import '../widgets/session_mode_switcher.dart';
import 'active_session_screen.dart';

class SessionEntryScreen extends ConsumerStatefulWidget {
  const SessionEntryScreen({super.key});

  @override
  ConsumerState<SessionEntryScreen> createState() => _SessionEntryScreenState();
}

class _SessionEntryScreenState extends ConsumerState<SessionEntryScreen> {
  SessionMode _mode = SessionMode.create;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    ref.listenManual(sessionControllerProvider, (previous, current) async {
      await handleSessionStates(context, previous: previous, current: current);
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ref.read(selectableNoteProvider.notifier).update((s) => s.init());
      },
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Scaffold(
          appBar: AppBar(title: const Text('إدارة الجلسة'), centerTitle: true),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SessionModeSwitcher(
                mode: _mode,
                onChanged: (m) => setState(() => _mode = m),
              ),
              const SizedBox(height: 30),

              IndexedStack(
                index: _mode == SessionMode.create ? 0 : 1,
                children: [
                  const CreateSessionForm(),
                  JoinSessionForm(controller: _codeController),
                ],
              ),
              const SizedBox(height: 30),

              const Text('الجلسة المفتوحة'),
              const SizedBox(height: 22),
              const SessionRunningCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class SessionRunningCard extends ConsumerWidget {
  const SessionRunningCard({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final currentSession = ref.watch(sessionProvider);

    if (currentSession == null) return const Text('لا توجد جلسات مفتوحة');

    final asyncNote = ref.watch(
      getNoteByIdProvider(currentSession.noteId ?? ''),
    );

    return asyncNote.when(
      data: (note) {
        return ConditionalBuilder(
          condition: note != null,
          fallback: (_) =>
              const Center(child: Text('الملاحظة المرتبطة بهذه الجلسة محذوفة')),
          builder: (_) {
            final params = SelectedNotePreviewConfig(
              note: note!,
              statusLabel: currentSession.status == SessionStatus.active
                  ? 'جلسة مفتوحة'
                  : 'جلسة مغلقة',
              onButtonPressed: () =>
                  context.pushTo(const ActiveSessionScreen()),
              onCardPressed: () => context.pushTo(const ActiveSessionScreen()),
              textButtonLabel: 'دخول',
              textButtonIcon: Icons.open_in_new,
            );
            return SelectedNotePreviewCard(params);
          },
        );
      },
      loading: () {
        return Skeletonizer(
          child: SelectedNotePreviewCard(SelectedNotePreviewConfig.fake()),
        );
      },
      error: (error, stackTrace) {
        return const Center(child: Text('حدث خطأ أثناء تحميل الجلسة'));
      },
    );
  }
}
