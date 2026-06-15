import '../entities/session.dart';
import '../entities/session_member.dart';

abstract interface class SessionRepository {
  Future<Session> createSession(Session session);

  Future<void> deleteSession(String sessionId);

  Future<void> addMemberToSession(SessionMember member);

  Future<void> removeMember(SessionMember member);

  Future<Session> getSessionByCode({required String sessionCode});

  Stream<List<SessionMember>> getMembersStream(String sessionId);

  Future<void> leaveSession(SessionMember member);
}
