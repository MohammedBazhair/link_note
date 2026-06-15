import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/errors/exceptions.dart';
import 'package:link_note/core/presentation/providers/core_providers.dart';
import 'package:link_note/features/session/injection.dart';
import '../../../../core/constants/internal_constants/log.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/session_member.dart';
import '../../domain/entities/sub/session_member_role.dart';
import '../../domain/repository/session_repository.dart';
import 'session_state.dart';

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    return const InitialSessionState();
  }

   SessionRepository get _sessionRepository=> ref.read(sessionRepositoryProvider);

  Future<void> createSession(Session session) async {
    try {
      state = const LoadingSessionState();
      if (state.session != null) {
        throw const CreateSessionException(
          'لا يمكنك أنشاء أكثر من جلسة في نفس الوقت',
        );
      }

      final createdSession = await _sessionRepository.createSession(session);

      final member = SessionMember(
        sessionId: createdSession.id!,
        memberId: createdSession.hostId,
        role: SessionMemberRole.host,
      );

      await _sessionRepository.addMemberToSession(member);

      state = CreateSessionState(
        session: createdSession,
        currentMember: member,
      );
    } on AppException catch (e) {
      state = ErrorSessionState(message: e.message);
    }
  }

  Stream<List<SessionMember>> fetchMembersOfSession() {
    final sessionId = state.session?.id;
    if (sessionId == null) return const Stream.empty();

    return _sessionRepository.getMembersStream(sessionId).handleError((e, st) {
      Logger.log(error: e, stackTrace: st);
    });
  }

  Future<void> joinSessionByCode({required String sessionCode}) async {
    try {
      final memberId = ref.read(userControllerProvider).profile.userId;

      state = const LoadingSessionState();

      final session = await _sessionRepository.getSessionByCode(
        sessionCode: sessionCode,
      );

      final member = SessionMember(
        sessionId: session.id!,
        memberId: memberId,
        role: SessionMemberRole.member,
      );

      await _sessionRepository.addMemberToSession(member);

      state = JoinSessionState(session: session, currentMember: member);
    } on AppException catch (e) {
      state = ErrorSessionState(message: e.message);
    } catch (e) {
      state = ErrorSessionState(
        message: 'فشل الانضمام إلى الجلسة، الرجاء إدخال كود الجلسة المطلوبة',
      );
      Logger.log(error: e);
    }
  }

  Future<void> leaveSession() async {
    try {
      final currentMember = state.currentMember;

      if (currentMember == null) return;

      await _sessionRepository.leaveSession(currentMember);

      state = const MemberLeavedSessionState();
    } on AppException catch (e) {
      state = ErrorSessionState(message: e.message);
    }
  }

  Future<void> endSession() async {
    try {
      final sessionId = state.session?.id;
      if (sessionId == null) return;

      await _sessionRepository.deleteSession(sessionId);
      state = const EndedSessionState();
    } on AppException catch (e) {
      state = ErrorSessionState(message: e.message);
    }
  }
}
