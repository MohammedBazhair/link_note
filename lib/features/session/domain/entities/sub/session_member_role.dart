enum SessionMemberRole {
  host('مالك'),
  member('عضو');

  const SessionMemberRole(this.label);

  final String label;

  static SessionMemberRole fromString(String roleString) {
    return values.byName(roleString);
  }
}
