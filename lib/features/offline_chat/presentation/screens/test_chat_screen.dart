import 'package:flutter/material.dart';
import 'package:link_note/features/offline_chat/domain/entities/message_type.dart';
import '../../../../core/constants/assets/app_assets.dart';
import '../../domain/entities/message.dart';
import '../controllers/chat_providers.dart';
import '../widgets/chat/chat_input.dart';
import '../widgets/chat/message_list.dart';

class TestChatScreen extends StatelessWidget {
  const TestChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تجربة الدردشة')),
      body: const Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            Expanded(
              child: MessageList(peerId: '', myId: 'user_1'),
            ),

            ChatInput(peerId: ''),
          ],
        ),
      ),
    );
  }
}

final ChatMessagesMap mockMessages = {
  // 1️⃣ رسالة قصيرة جدًا
  '1': Message(
    id: '1',
    senderUserId: 'user_1',
    type: MessageType.text,
    text: 'مرحبا',
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 15)),
  ),

  // 2️⃣ رد بسيط
  '2': Message(
    id: '2',
    senderUserId: 'user_2',
    type: MessageType.text,
    text: 'أهلاً 👋',
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 14)),
    replyToMessageId: '1',
  ),

  // 3️⃣ نص طويل (اختبار wrap + الوقت)
  '3': Message(
    id: '3',
    senderUserId: 'user_1',
    type: MessageType.text,
    text:
        'السلام عليكم ورحمة الله وبركاته، هذه رسالة طويلة جدًا الهدف منها اختبار التفاف النص، '
            'ومحاذاة الوقت، وسلوك الفقاعة عند امتلاء أكثر من سطر في واجهة الدردشة. ' *
        50,
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 12)),
  ),

  // 4️⃣ رد على رسالة طويلة
  '4': Message(
    id: '4',
    senderUserId: 'user_2',
    type: MessageType.text,
    text: 'الرسالة واضحة جدًا 👍',
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 11)),
    replyToMessageId: '3',
  ),

  // 5️⃣ Emoji فقط
  '5': Message(
    id: '5',
    senderUserId: 'user_1',
    type: MessageType.text,
    text: '😂😂😂',
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 10)),
  ),

  // 6️⃣ رسالة إنجليزية (LTR)
  '6': Message(
    id: '6',
    senderUserId: 'user_2',
    type: MessageType.text,
    text: 'This is an English message to test LTR behavior.',
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 9)),
  ),

  // 7️⃣ رد على رسالة إنجليزية
  '7': Message(
    id: '7',
    senderUserId: 'user_1',
    type: MessageType.text,
    text: 'Looks good 👍',
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 8)),
    replyToMessageId: '6',
  ),

  // 8️⃣ رسالة مختلطة عربي + إنجليزي
  '8': Message(
    id: '8',
    senderUserId: 'user_2',
    type: MessageType.text,
    text: 'هذا اختبار Mixed RTL & LTR داخل نفس الرسالة.',
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 7)),
  ),

  // 9️⃣ رسالة بدون نص (fallback)
  '9': Message(
    id: '9',
    senderUserId: 'user_1',
    type: MessageType.text,
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 6)),
  ),

  // 🔟 رسالة صورة
  '10': Message(
    id: '10',
    senderUserId: 'user_2',
    type: MessageType.image,
    filePath: Assets.imagesBackground,
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 5)),
  ),

  // 1️⃣1️⃣ رد على صورة
  '11': Message(
    id: '11',
    senderUserId: 'user_1',
    type: MessageType.text,
    text: 'الصورة جميلة 🔥',
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 4)),
    replyToMessageId: '10',
  ),

  // 1️⃣2️⃣ رسالة طويلة جدًا جدًا (اختبار اقرأ المزيد)
  '12': Message(
    id: '12',
    senderUserId: 'user_2',
    type: MessageType.text,
    text:
        'هذه رسالة طويلة جدًا جدًا جدًا الهدف منها اختبار ميزة اقرأ المزيد '
        'واستكمال النص عند الضغط عليها. '
        'يجب التأكد أن الوقت يبقى في مكانه الصحيح '
        'وأن الفقاعة لا تتكسر مهما زاد عدد الأحرف.',
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 3)),
  ),

  // 1️⃣3️⃣ رد متسلسل (reply chain)
  '13': Message(
    id: '13',
    senderUserId: 'user_1',
    type: MessageType.text,
    text: 'تمام فهمت 👍',
    chatId: 'chat_123',
    time: DateTime.now().subtract(const Duration(minutes: 2)),
    replyToMessageId: '12',
  ),

  // 1️⃣4️⃣ آخر رسالة (الآن)
  '14': Message(
    id: '14',
    senderUserId: 'user_2',
    type: MessageType.handshake,
    text: '👋',
    chatId: 'chat_123',
    time: DateTime.now(),
  ),
};
