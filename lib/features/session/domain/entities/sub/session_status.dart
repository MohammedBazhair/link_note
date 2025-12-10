enum SessionStatus {
  active,
  closed;

 static SessionStatus fromString(String statusString) {
    return switch (statusString) {
      'active' => SessionStatus.active,
      'closed' => SessionStatus.closed,
      _ => SessionStatus.closed,
    };
  }
}
