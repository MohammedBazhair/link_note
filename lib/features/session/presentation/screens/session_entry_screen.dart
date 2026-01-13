import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../note/presentation/widgets/note_tile.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/session_mode.dart';
import '../../helpers.dart';
import '../controllers/session_controller.dart';
import '../widgets/create_session_form.dart';
import '../widgets/join_session_form.dart';
import '../widgets/session_mode_switcher.dart';

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

  // ---------------- CREATE SESSION ----------------

  Future<void> _createSession() async {
    final selectable = ref.read(selectableNoteProvider);

    if (!selectable.hasNoteId) {
      context.showSnakbar('يجب اختيار ملاحظة أولاً');
      return;
    }

    final hostId = ref.read(userControllerProvider.notifier).currentUser?.id;

    if (hostId == null) {
      await context.pushTo(const SignInScreen());
      return;
    }

    final session = Session(hostId: hostId, noteId: selectable.noteId);

    await ref.read(sessionControllerProvider.notifier).createSession(session);
  }

  // ---------------- JOIN SESSION ----------------

  Future<void> _joinSession() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      context.showSnakbar('الرجاء إدخال رمز الجلسة');
      return;
    }

    final userId = ref.read(userControllerProvider).profile.userId;

    await ref
        .read(sessionControllerProvider.notifier)
        .joinSessionByCode(memberId: userId, sessionCode: code);
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SessionModeSwitcher(
              mode: _mode,
              onChanged: (m) => setState(() => _mode = m),
            ),
            const SizedBox(height: 30),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _mode == SessionMode.create
                  ? CreateSessionForm(onCreate: _createSession)
                  : JoinSessionForm(
                      controller: _codeController,
                      onJoin: _joinSession,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
