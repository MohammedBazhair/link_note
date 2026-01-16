import 'dart:io';

import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/features/database/remote/remote_database_service.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/session_member.dart';
import '../../domain/repository/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._remoteDatabase);

  final RemoteDatabaseService _remoteDatabase;

  @override
  Future<Result<Session>> createSession(Session session) async {
    try {
      await _remoteDatabase.deleteWhere(
        filters: {'host_id': session.hostId},
        table: ExternalConsts.sessionsTable,
      );

      final rawSession = await _remoteDatabase.insertRow(
        map: session.toMap(),
        table: ExternalConsts.sessionsTable,
      );

      return Result.ok(Session.fromMap(rawSession));
    } on SocketException catch (_) {
      return Result.error(
        'Failed to create session, please check your internet connection.',
      );
    } on Exception catch (_) {
      return Result.error('Failed to create session, please try again.');
    }
  }

  @override
  Future<String?> addMemberToSession({
    required SessionMember member,
    required Session session,
  }) async {
    try {
      Logger.log(message: 'Adding member to session');
      final map = await _remoteDatabase.insertRow(
        map: member.toMap(),
        table: ExternalConsts.sessionMembersTable,
      );
      Logger.log(message: map.toString());
      return null;
    } catch (e) {
      Logger.log(error: e);
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
  Future<Result<Session>> getSessionByCode({
    required String sessionCode,
  }) async {
    try {
      final map = await _remoteDatabase.readRowsWhere(
        table: ExternalConsts.sessionsTable,
        filters: {'session_code': sessionCode},
      );

      if (map.isEmpty) {
        return Result.error(
          'The session is not found, enter another session code.',
        );
      }
      final session = Session.fromMap(map.first);
      if (session.id == null) {
        return Result.error('Failed to get the session without id.');
      }

      return Result.ok(session);
    } on SocketException catch (_) {
      return Result.error('Check your connection first to get the session');
    } on Exception catch (_) {
      return Result.error('Failed to get the session, try again later');
    }
  }

  @override
  Stream<List<SessionMember>> getMembersStream(String sessionId) {
    final stream = _remoteDatabase.readRowsRealTime(
      table: ExternalConsts.sessionMembersTable,
      primaryKey: ['session_id', 'member_id'],
      column: 'session_id',
      value: sessionId,
    );

    return stream.map((raw) {
      final members = List<SessionMember>.from(raw.map(SessionMember.fromMap));
      members.sort((a, b) {
        // If a is host and b is not → place a before b
        if (a.isHost && !b.isHost) return -1;

        // If b is host and a is not → place b before a
        if (!a.isHost && b.isHost) return 1;

        // If both are hosts or both are not → keep their order
        return 0;
      });
      return members;
    });
  }
}
