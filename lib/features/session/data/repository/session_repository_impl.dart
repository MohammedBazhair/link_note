import 'package:flutter/widgets.dart';

import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/features/database/remote/remote_database_service.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/session_member.dart';
import '../../domain/repository/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._remoteDatabase);

  final RemoteDatabaseService _remoteDatabase;

  @override
  Future<Session?> createSession(Session session) async {
    try {
      await _remoteDatabase.deleteWhere(
        filters: {'host_id': session.hostId},
        table: ExternalConsts.sessionsTable,
      );

      final rawSession = await _remoteDatabase.insertRow(
        map: session.toMap(),
        table: ExternalConsts.sessionsTable,
      );

      return Session.fromMap(rawSession);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  @override
  Future<String?> addMemberToSession({
    required SessionMember member,
    required Session session,
  }) async {
    try {
      await _remoteDatabase.insertRow(
        map: member.toMap(),
        table: ExternalConsts.sessionMembersTable,
      );
      return null;
    } catch (_) {
      return 'Failed to add member to session. Please try again, or check your internet connection.';
    }
  }

  @override
  Future<String?> deleteSession(Session? session) async {
    try {
      if (session == null || session.id == null) {
        return 'Session ID is null. Cannot delete session.';
      }

      await _remoteDatabase.delete(
        id: session.id!,
        column: 'id',
        table: ExternalConsts.sessionsTable,
      );
      return null;
    } catch (_) {
      return 'Failed to delete session. Please try again, or check your internet connection.';
    }
  }

  @override
  Future<String?> removeMember({
    required SessionMember member,
    required Session session,
  }) async {
    try {
      if (session.id == null) {
        return 'Session is not found, Cannot remove member from it.';
      }

      final filters = {'session_id': session.id!, 'member_id': member.memberId};

      await _remoteDatabase.deleteWhere(
        table: ExternalConsts.sessionMembersTable,
        filters: filters,
      );
      return null;
    } catch (e) {
      return 'Failed to remove member from session. Please try again, or check your internet connection.';
    }
  }

  @override
  Future<Session?> getSessionByCode({required String sessionCode}) async {
    try {
      final map = await _remoteDatabase.readRowsWhere(
        table: ExternalConsts.sessionsTable,
        filters: {'session_code': sessionCode},
      );

      return Session.fromMap(map.first);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<Set<SessionMember>> getMembersStream(String sessionId) {
    final stream = _remoteDatabase.readRowsRealTime(
      table: ExternalConsts.sessionMembersTable,
      primaryKey: ['session_id', 'member_id'],
      column: 'session_id',
      value: sessionId,
    );

    return stream.map((raw) => Set.from(raw.map(SessionMember.fromMap)));
  }
}
