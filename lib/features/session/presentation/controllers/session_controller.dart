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
    final createdSession = await _sessionRepository.createSession(session);

    if (createdSession?.id == null) {
      state = ErrorSessionState(
        message: 'Faild to create session, try again, or check your connection',
      );

      return;
    }

    final member = SessionMember(
      sessionId: createdSession!.id!,
      memberId: createdSession.hostId,
      role: SessionMemberRole.host,
    );

    state = CreateSessionState(session: createdSession);
    await addMemberToSession(member);
  }

  Future<void> addMemberToSession(SessionMember member) async {
    try {
      if (state.session == null) throw ArgumentError.value('No active session');

      await _sessionRepository.addMemberToSession(
        member: member,
        session: state.session!,
      );

      final updatedMembers = {...state.members, member};

      state = AddMemberState(members: updatedMembers,session: state.session);
    } on ArgumentError catch (e) {
      state = ErrorSessionState(message: e.toString(), session: state.session,members: state.members);
    } catch (e) {
      state = ErrorSessionState(
        session: state.session,
        members: state.members,
        message:
            'Failed to add member, please try again or check your connection.',
      );
    }
  }

  Future<void> joinSessionByCode(String sessionCode) async {
    final session = await _sessionRepository.getSessionByCode(
      sessionCode: sessionCode,
    );

    state = (session != null)
        ? JoinSessionState(session: session,members: state.members)
        : ErrorSessionState(message: 'Session not found',members: state.members,session: state.session);
  }

  Future<void> endSession() async {
    print('session');
    print(state.session);
    if (state.session == null) return;
    final error = await _sessionRepository.deleteSession(state.session);

    state = (error == null)
        ? EndedSessionState()
        : ErrorSessionState(message: error);
  }
}
