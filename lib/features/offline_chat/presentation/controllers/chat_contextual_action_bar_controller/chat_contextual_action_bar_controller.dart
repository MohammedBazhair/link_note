import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/constants/internal_constants/log.dart';
import 'package:link_note/core/extensions/extensions.dart';
import 'package:link_note/features/offline_chat/domain/entities/message.dart';
import 'chat_contextual_action_bar_state.dart';

class ChatContextualActionBarController
    extends Notifier<ChatContextualActionBarState> {
  @override
  ChatContextualActionBarState build() {
    return const ChatContextualActionBarState();
  }

  void closeActionBar() {
    state = const ChatContextualActionBarState();
  }

  void selectMessage(Message message) {
    state = state.copyWith(selectedMessage: message, actionBarOpened: true);
  }

  void copyMessageText() async {
    try {
      final currentContent = state.selectedMessage?.text;
      if (currentContent == null) return;
      
      await currentContent.copyToClipboard();

      state = const ChatContextualActionBarState(
        successMessage: 'تم نسخ الرسالة للحافظة بنجاح',
      );
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      state = state.copyWith(
        errorMessage: 'حصلت هناك مشكلة أثناء نسخ محتوى الرسالة المحددة',
      );
    }
  }
}
