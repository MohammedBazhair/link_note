import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/session.dart';
import '../../domain/repository/session_repository.dart';
import 'session_state.dart';

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>(
      (_) => GetIt.I<SessionController>(),
    );

class SessionController extends StateNotifier<SessionState> {
  SessionController(this._sessionRepository) : super(InitialSessionState());
  final SessionRepository _sessionRepository;

  Future<void> createSession(Session session) async {
    final error = await _sessionRepository.createSession(session);

    state = (error == null)
        ? CreateSessionState(session: session)
        : ErrorSessionState(message: error);
  }

  Future<void> joinSessionByCode(String sessionCode) async {
    final session = await _sessionRepository.getSessionByCode(sessionCode: sessionCode);

    state = (session != null)
        ? JoinSessionState(session: session)
        : ErrorSessionState(message: 'Session not found');
  }



  Future<void> endSession() async {
    if (state.session == null) return;
    final error = await _sessionRepository.deleteSession(state.session);

    state = (error == null)
        ? EndedSessionState()
        : ErrorSessionState(message: error);
  }
}
