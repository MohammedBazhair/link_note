import '../entities/session.dart';
import '../entities/session_member.dart';

abstract interface class SessionRepository {
  Future<String?> createSession(Session session);

  Future<String?> deleteSession(Session? session);

  Future<void> addMemberToSession({
    required SessionMember member,
    required Session session,
  });

  Future<String?> removeMember({
    required SessionMember member,
    required Session session,
  });

  Future<Session?> getSessionByCode({required String sessionCode});

  Future<List<SessionMember>> getMembers(String sessionId);
}
