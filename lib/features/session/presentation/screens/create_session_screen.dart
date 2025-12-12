import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../../domain/entities/session.dart';
import '../controllers/session_controller.dart';
import '../controllers/session_state.dart';
import 'session_screen.dart';

class CreateSessionScreen extends ConsumerStatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  ConsumerState<CreateSessionScreen> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends ConsumerState<CreateSessionScreen> {
  Future<void> _createSession() async {
    final loading = ref.read(loadingProvider.notifier);
    loading.state = true;

    final hostId = ref.read(userControllerProvider.notifier).currentUser?.id;

    if (hostId == null) {
      loading.state = false;
      await context.pushTo(const SignInScreen());
      return;
    }

    final session = Session(hostId: hostId);

    await ref.read(sessionControllerProvider.notifier).createSession(session);

    loading.state = false;
    await context.pushTo(const SessionScreen());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionControllerProvider, (_, next) {
      switch (next) {
        case InitialSessionState():
          break;
        case CreateSessionState():
          context.showSnakbar('Session created successfully');
        case JoinSessionState():
          context.showSnakbar('Joined session successfully');
        case EndedSessionState():
          context.showSnakbar('Ended session successfully');
        case ErrorSessionState(:final message):
          context.showSnakbar(message);
        case AddMemberState():
          context.showSnakbar('Member added successfully');
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Create Session')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Consumer(
              builder: (_, ref, __) {
                final isLoading = ref.watch(loadingProvider);
                return isLoading
                    ? const LinearProgressIndicator()
                    : ElevatedButton(
                        onPressed: _createSession,
                        child: const Text('Create Session'),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
