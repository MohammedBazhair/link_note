import '../../../../core/errors/result.dart';
import '../entities/session.dart';
import '../entities/session_member.dart';

abstract interface class SessionRepository {
  Future<Result<Session>> createSession(Session session);

  Future<String?> deleteSession(Session? session);

  Future<void> addMemberToSession({
    required SessionMember member,
    required Session session,
  });

  Future<String?> removeMember({
    required SessionMember member,
    required Session session,
  });

  Future<Result<Session>> getSessionByCode({required String sessionCode});

  Stream<List<SessionMember>> getMembersStream(String sessionId);

}
