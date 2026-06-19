import 'package:link_note/core/constants/external_constants/external_constants.dart';
import 'package:link_note/core/features/database/local/local_database_service.dart';
import 'package:link_note/features/offline_chat/domain/datasources/messages_local_data_source.dart';
import 'package:link_note/features/offline_chat/domain/entities/message.dart';
import 'package:link_note/features/offline_chat/domain/entities/reaction_emoji.dart';

class MessagesLocalDataSourceImpl implements MessagesLocalDataSource {
  MessagesLocalDataSourceImpl(this._db);

  final LocalDatabaseService _db;

  final _messagesTable = ExternalConsts.messagesTable;

  @override
  Future<void> saveMessage(Message message) async {
    await _db.insertRow(map: message.toMap(), table: _messagesTable);
  }

  @override
  Future<Message?> getMessageById(String messageId) async {
    final row = await _db.readRow(
      id: messageId,
      column: 'id',
      table: _messagesTable,
    );

    if (row.isEmpty) return null;

    return Message.fromMap(row);
  }

  @override
  Future<List<Message>> getChatMessages(String chatId) async {
    final rows = await _db.readRowsWhere(
      table: _messagesTable,
      filters: {'chat_id': chatId},
    );

    return rows.map(Message.fromMap).toList();
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _db.deleteWhere(table: _messagesTable, filters: {'id': messageId});
  }

  @override
  Future<void> deleteChatMessages(String chatId) async {
    await _db.deleteWhere(table: _messagesTable, filters: {'chat_id': chatId});
  }

  @override
  Future<void> updateReaction({
    required String messageId,
    required ReactionEmoji? reaction,
  }) async {
    await _db.update(
      updated: {'reaction_emoji': reaction?.code},
      value: messageId,
      column: 'id',
      table: _messagesTable,
    );
  }
}
