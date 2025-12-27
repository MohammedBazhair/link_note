class ExternalConsts {
  ExternalConsts._();

  static const imagesBucket = 'images';
  static const notesTable = 'notes';
  static const profilesTable = 'profiles';
  static const sessionsTable = 'sessions';
  static const sessionMembersTable = 'session_members';

  static const maxfileMbSize = 3.0;

  static const imagesAppCache = 'imagesAppCache';

  static const supabaseUrl = 'https://fyfutnuahjknmvdorkwa.supabase.co';
  static const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5ZnV0bnVhaGprbm12ZG9ya3dhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5MDY1MDgsImV4cCI6MjA3OTQ4MjUwOH0.QMY5rWu8kzSJdayLsnSiUQnQLkMNyimRImNvrDsBu30';
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
  static const profileUserKey = 'user_id';
  static const aiApiUrl =
      'https://fyfutnuahjknmvdorkwa.supabase.co/functions/v1/generate-ai';
}
