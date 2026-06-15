import 'dart:io';
import 'package:link_note/core/constants/external_constants/external_constants.dart';
import 'package:link_note/core/constants/internal_constants/log.dart';
import 'package:link_note/core/errors/exceptions.dart';
import 'package:link_note/core/features/database/remote/remote_database_service.dart';
import 'package:link_note/features/session/domain/entities/session.dart';
import 'package:link_note/features/session/domain/entities/session_member.dart';
import 'package:link_note/features/session/domain/repository/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._remoteDatabase);

  final RemoteDatabaseService _remoteDatabase;

  @override
  Future<Session> createSession(Session session) async {
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
    } on SocketException catch (_) {
      throw const InternetException(
        'فشل إنشاء الجلسة، يرجى التحقق من اتصالك بالإنترنت.',
      );
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      throw const CreateSessionException();
    }
  }

  @override
  Future<void> addMemberToSession(SessionMember member) async {
    try {
      await _remoteDatabase.insertRow(
        map: member.toMap(),
        table: ExternalConsts.sessionMembersTable,
      );
    } on SocketException catch (_) {
      throw const InternetException(
        'فشل إضافة العضو للجلسة، يرجى التحقق من اتصالك بالإنترنت.',
      );
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      throw const AddMemberToSessionException();
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      if (sessionId.isEmpty) {
        throw const RemoveSessionException();
      }

      await _remoteDatabase.delete(
        id: sessionId,
        column: 'id',
        table: ExternalConsts.sessionsTable,
      );
    } on SocketException catch (_) {
      throw const InternetException(
        'فشلت عملية إزالة الجلسة، يرجى التحقق من اتصالك بالإنترنت.',
      );
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      throw const RemoveSessionException();
    }
  }

  @override
  Future<void> removeMember(SessionMember member) async {
    try {
      if (member.sessionId.isEmpty) {
        throw const RemoveMemberFromSessionException();
      }

      final filters = {
        'session_id': member.sessionId,
        'member_id': member.memberId,
      };

      await _remoteDatabase.deleteWhere(
        table: ExternalConsts.sessionMembersTable,
        filters: filters,
      );
    } on SocketException catch (_) {
      throw const InternetException(
        'فشلت عملية إزالة العضو من الجلسة، يرجى التحقق من اتصالك بالإنترنت.',
      );
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      throw const RemoveMemberFromSessionException();
    }
  }

  @override
  Future<Session> getSessionByCode({required String sessionCode}) async {
    try {
      final map = await _remoteDatabase.readRowsWhere(
        table: ExternalConsts.sessionsTable,
        filters: {'session_code': sessionCode},
      );

      if (map.isEmpty) throw Exception();

      final session = Session.fromMap(map.first);

      if (session.id == null) {
        throw const GetSessionException('حدث خطأ في قراءة بيانات الجلسة.');
      }

      return session;
    } on SocketException catch (_) {
      throw const InternetException(
        'تعذر جلب بيانات الجلسة، يرجى التحقق من اتصالك بالإنترنت.',
      );
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      throw const GetSessionException();
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

  @override
  Future<void> leaveSession(SessionMember member) async {
  if (member.isHost) {
    await deleteSession(member.sessionId);
    return;
  }
  
  await removeMember(member);

  }
}
