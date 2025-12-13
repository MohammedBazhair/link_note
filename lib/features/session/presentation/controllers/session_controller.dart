import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/session.dart';
import '../../domain/entities/session_member.dart';
import '../../domain/entities/sub/session_member_role.dart';
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
    try {
      final createdSession = await _sessionRepository.createSession(session);

      if (createdSession?.id == null) throw ArgumentError.notNull();

      final member = SessionMember(
        sessionId: createdSession!.id!,
        memberId: createdSession.hostId,
        role: SessionMemberRole.host,
      );

      await _addMemberToSession(member, createdSession);
      state = CreateSessionState(session: createdSession);
    } catch (e) {
      state = ErrorSessionState(
        message: 'Failed to create session, please try again.',
      );
    }
  }

  Future<void> _addMemberToSession(
    SessionMember member,
    Session session,
  ) async {
    await _sessionRepository.addMemberToSession(
      member: member,
      session: session,
    );
  }

  Stream fetchMembersOfSession() {
    final sessionId = state.session?.id;
    if (sessionId == null) return const Stream.empty();

    return _sessionRepository.getMembersStream(sessionId);
  }

  Future<void> joinSessionByCode({
    required String sessionCode,
    required String memberId,
  }) async {
    try {
      final session = await _sessionRepository.getSessionByCode(
        sessionCode: sessionCode,
      );

      if (session?.id == null) throw ArgumentError.notNull();
 
      final member = SessionMember(
        sessionId: session!.id!,
        memberId: memberId,
        role: SessionMemberRole.member,
      );

      await _addMemberToSession(member, session);
      state = JoinSessionState(session: session);
    }  catch (e) {
      state = ErrorSessionState(message: 'Failed to join session');
      debugPrint(e.toString());
    }
  }

  Future<void> endSession() async {
    if (state.session == null) return;
    final error = await _sessionRepository.deleteSession(state.session);

    state = (error == null)
        ? EndedSessionState()
        : ErrorSessionState(message: error,session: state.session);
  }
}
