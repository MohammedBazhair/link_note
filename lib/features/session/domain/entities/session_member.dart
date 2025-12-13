
import 'sub/session_member_role.dart';

class SessionMember  {
  SessionMember({
    required this.sessionId,
    required this.memberId,
    required this.role,
  });

  factory SessionMember.fromMap(Map<String, dynamic> map) {
    return SessionMember(
      sessionId: map['session_id'] as String,
      memberId: map['member_id'] as String,
      role: SessionMemberRole.fromString(map['role'] as String),
    );
  }

  

  final String sessionId;
  final String memberId;
  final SessionMemberRole role;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'session_id': sessionId,
      'member_id': memberId,
      'role': role.name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SessionMember &&
        other.sessionId == sessionId &&
        other.memberId == memberId ;
  }

  @override
  int get hashCode => sessionId.hashCode ^ memberId.hashCode;
}