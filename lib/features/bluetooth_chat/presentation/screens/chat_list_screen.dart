import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../user/presentation/controllers/user_providers.dart';
import '../controllers/chat_providers.dart';
import '../widgets/user_avatar_with_status.dart';
import 'chat_screen.dart';
import 'nearby_devices_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUserId = ref.read(getUserIdProvider);
    if (myUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الدردشات')),
        body: Column(
          spacing: 10,
          children: [
            const Text(
              'يجب أن تكون مسجل الدخول حتى تستطيع الدردشة',
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () {
                context.pushTo(const SignInScreen());
              },
              child: const Text('تسجيل الدخول'),
            ),
          ],
        ),
      );
    }
    final messages = ref.watch(chatControllerProvider);

    // قائمة جميع المستخدمين الذين تراسلناهم
    final chatUserIds = messages
        .map(
          (m) => m.senderUserId == myUserId
              ? _getOtherId(chatId: m.chatId, myUserId: myUserId)
              : m.senderUserId,
        )
        .toSet()
        .toList();
    final manager = ref.watch(connectionManagerProvider);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: AppBar(title: const Text('Chats')),
      body: chatUserIds.isEmpty
          ? const Center(
              child: Text('لا يوجد لديك دردشات بعد. اضغط + لبدء الدردشة'),
            )
          : ListView.builder(
              itemCount: chatUserIds.length,
              itemBuilder: (context, index) {
                final peerUserId = chatUserIds[index];
                final username = manager.getDisplayNameByUuid(peerUserId);
                final isconnected = manager.isConnected(peerUserId);
                return ListTile(
                  leading: UserAvatarWithStatus(connected: isconnected),
                  title: Text(username),
                  subtitle: Text(isconnected ? 'متصل' : 'غير متصل'),
                  onTap: () {
                    context.pushTo(
                      ChatScreen(
                        myId: myUserId,
                        peerUserId: peerUserId,
                        peerId: peerUserId,
                      ),
                    );
                  },
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        child: const Icon(Icons.person_add),
        onPressed: () {
          context.pushTo(NearbyDevicesScreen(myUserId: myUserId));
        },
      ),
    );
  }

  String _getOtherId({required String chatId, required String myUserId}) {
    final parts = chatId.split('_');
    if (parts.length != 2) return chatId;
    return parts[0] == myUserId ? parts[1] : parts[0];
  }
}
