import 'session_member.dart';

/// Stable key for session members family provider
class SessionMembersKey {
  const SessionMembersKey(this.memberIds, this.membersMap);

  final List<String> memberIds;
  final Map<String, SessionMember> membersMap;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionMembersKey &&
        other.memberIds.length == memberIds.length &&
        _listEquals(other.memberIds, memberIds);
  }

  @override
  int get hashCode => memberIds.join(',').hashCode;

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
