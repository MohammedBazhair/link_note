enum SessionMemberRole {
  host,
  member;

  static SessionMemberRole fromString(String roleString) {
    return switch (roleString) {
      'host' => SessionMemberRole.host,
      'member' => SessionMemberRole.member,
      _ => SessionMemberRole.member,
    };
  }
}
