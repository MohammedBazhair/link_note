class ExternalConsts {
  ExternalConsts._();

  static const imagesBucket = 'images';
  static const notesTable = 'notes';
  static const profilesTable = 'profiles';
  static const sessionsTable = 'sessions';
  static const sessionMembersTable = 'session_members';

  static const maxfileMbSize = 3.0;

  static const supabaseUrl = 'profiles';
  static const supabaseAnonKey = 'profiles';
  static const authRedirectUrl = 'https://bhf-s.github.io/auth/';

  static const createTableNotesQuery = 
  '''
  CREATE TABLE IF NOT EXISTS $notesTable (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    owner_id TEXT NULL,
    updated_at TEXT NOT NULL
  );
  ''';

  static const lastUserIdKey = 'user_id';
}
