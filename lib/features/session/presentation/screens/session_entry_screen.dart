import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/session_mode.dart';
import '../../handle_session_states.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ],
      ),
    );
  }
}
