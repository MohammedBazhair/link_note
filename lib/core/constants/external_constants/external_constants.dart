class ExternalConsts {
  ExternalConsts._();

  static const fontFamily = 'IBM Plex Sans Arabic';
  static const imagesBucket = 'images';
  static const databaseName = 'Link Note 2.0.db';
  static const notesTable = 'notes';
  static const syncChangesTable = 'sync_changes';
  static const syncStateTable = 'sync_state';
  static const profilesTable = 'profiles';
  static const sessionsTable = 'sessions';
  static const sessionMembersTable = 'session_members';
  static const messagesTable = 'messages';
  static const chatsTable = 'chats';
  static const qrSafeLimitBytes = 1800;

  static const maxfileMbSize = 3;

  static const supabaseUrl = 'https://fyfutnuahjknmvdorkwa.supabase.co';
  static const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5ZnV0bnVhaGprbm12ZG9ya3dhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5MDY1MDgsImV4cCI6MjA3OTQ4MjUwOH0.QMY5rWu8kzSJdayLsnSiUQnQLkMNyimRImNvrDsBu30';
  static const authRedirectUrl = 'linknote://login';

  static const createTableNotesQuery =
      '''
  CREATE TABLE IF NOT EXISTS $notesTable (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    owner_id TEXT NULL,
    updated_at TEXT NOT NULL,
    is_deleted INTEGER NOT NULL DEFAULT 0 CHECK (is_deleted IN (0, 1))
  );
  ''';
  static String createTableSyncChangesQuery =
      '''
      CREATE TABLE $syncChangesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''';

  static String createTableSyncStateQuery =
      '''
      CREATE TABLE $syncStateTable (
        table_name TEXT PRIMARY KEY,
        last_sync TEXT NOT NULL
      );
    ''';

  static String createTableMessages =
      '''
      CREATE TABLE $messagesTable(
        id TEXT PRIMARY KEY,
        reply_To_Message_Id TEXT,
        chat_id TEXT NOT NULL REFERENCES chats(id),
        sender_user_id TEXT NOT NULL,
        message_type INTEGER NOT NULL,
        text TEXT,
        reaction_emoji INTEGER,
        file_path TEXT,
        time TEXT NOT NULL,
      );
    ''';

  static String createTableChats =
      '''
      CREATE TABLE $chatsTable(
        id TEXT PRIMARY KEY,
        friend_id TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''';

  static String createIndexesOfsyncChangesQuery =
      '''
    CREATE INDEX idx_sync_changes_table_record ON $syncChangesTable (table_name, record_id);
    CREATE INDEX idx_sync_changes_table_name ON $syncChangesTable (table_name);
    ''';

  static String createIndexesOfChats=
  '''
    CREATE INDEX idx_message_text_content ON $messagesTable (text,chat_id);
    CREATE INDEX idx_chat_id ON $messagesTable (chat_id);
  ''';


  static const lastUserIdKey = 'user_id';
  static const profileUserKey = 'user_profile';
  static const aiApiUrl =
      'https://fyfutnuahjknmvdorkwa.supabase.co/functions/v1/generate-ai';
  static const creditsKey = 'credits';

}
