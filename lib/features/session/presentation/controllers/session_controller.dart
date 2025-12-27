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
  SessionController(this._sessionRepository)
    : super(const InitialSessionState());
  final SessionRepository _sessionRepository;

  Future<void> createSession(Session session) async {
    try {
      state = const LoadingSessionState();
      if (state.session != null) {
        state = ErrorSessionState(
          message: 'Cannot start a new session. End the current session first.',
        );
        return;
      }

      final result = await _sessionRepository.createSession(session);
      if (result.hasError) throw Exception(result.errorMessage);

      final createdSession = result.value;
      if (createdSession?.id == null) throw ArgumentError.notNull();

      final member = SessionMember(
        sessionId: createdSession!.id!,
        memberId: createdSession.hostId,
        role: SessionMemberRole.host,
      );

      await _addMemberToSession(member, createdSession);
      state = CreateSessionState(
        session: createdSession,
        currentMember: member,
      );
    } catch (e) {
      state = ErrorSessionState(message: e.toString());
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

  Stream<Set<SessionMember>> fetchMembersOfSession() {
    final sessionId = state.session?.id;
    if (sessionId == null) return Stream.value({});

    return _sessionRepository.getMembersStream(sessionId);
  }

  Future<void> joinSessionByCode({
    required String sessionCode,
    required String memberId,
  }) async {
    try {
      final result = await _sessionRepository.getSessionByCode(
        sessionCode: sessionCode,
      );

      if (result.hasError) throw Exception(result.errorMessage);

      final session = result.value;
      

      final member = SessionMember(
        sessionId: session!.id!,
        memberId: memberId,
        role: SessionMemberRole.member,
      );

      await _addMemberToSession(member, session);
      state = JoinSessionState(session: session, currentMember: member);
    } catch (e) {
      state = ErrorSessionState(message: 'Failed to join session');
      debugPrint(e.toString());
    }
  }

  Future<void> leaveSession() async {
    try {
      if (state.currentMember == null || state.session == null) {
        throw ArgumentError.notNull();
      }

      if (state.currentMember!.isHost) {
        await endSession();
        return;
      }

      final error = await _sessionRepository.removeMember(
        member: state.currentMember!,
        session: state.session!,
      );
      if (error != null) throw Exception();
      state = const MemberLeavedSessionState();
    } catch (e) {
      debugPrint(e.toString());
      state = ErrorSessionState(
        message: 'Failed to leave the session, please try again.',
      );
    }
  }

  Future<void> endSession() async {
    if (state.session == null) return;
    final error = await _sessionRepository.deleteSession(state.session);

    state = (error == null)
        ? const EndedSessionState()
        : ErrorSessionState(message: error);
  }
}
