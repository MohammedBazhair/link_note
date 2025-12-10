import 'sub/session_status.dart';

class Session {
  Session({
    required this.id,
    required this.noteId,
    required this.hostId,
    required this.status,
  });

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as String?,
      noteId: map['note_id'] as String?,
      hostId: map['host_id'] as String,
      status: SessionStatus.fromString(map['status'] as String),
    );
  }

  final String? id;
  final String? noteId;
  final String hostId;
  final SessionStatus status;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': ?id,
      'noteId': noteId,
      'hostId': hostId,
      'status': status.name,
    };
  }
}
