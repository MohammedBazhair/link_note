// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'sub/session_status.dart';

class Session {

  factory Session( {required String hostId,
String? noteId   
  }) {
    return Session._(
      noteId: noteId,
      hostId: hostId,
      status:SessionStatus.active,
      sessionCode: generateSessionCode(),
    );
  }

  Session._({
     this.id,
     this.noteId,
    required this.hostId,
    required this.status,
    required this.sessionCode,
  });

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session._(
      id: map['id'] as String?,
      noteId: map['note_id'] as String?,
      hostId: map['host_id'] as String,
      status: SessionStatus.fromString(map['status'] as String),
      sessionCode: map['session_code'] as String,
    );
  }



  final String? id;
  final String? noteId;
  final String hostId;
  final SessionStatus status;
  final String sessionCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': ?id,
      'note_id': noteId,
      'host_id': hostId,
      'status': status.name,
      'session_code': sessionCode,
    };
  }

  @override
  String toString() {
    return 'Session(id: $id, noteId: $noteId, hostId: $hostId, status: $status, sessionCode: $sessionCode)';
  }
}

String generateSessionCode([int length = 5]) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // remove ambiguous chars
  final rnd = Random.secure();
  return List.generate(length, (_) => chars[rnd.nextInt(chars.length)]).join();
}
