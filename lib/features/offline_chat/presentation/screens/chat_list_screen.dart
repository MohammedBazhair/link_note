import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/features/offline_chat/presentation/screens/test_reaction_page.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../user/presentation/controllers/user_providers.dart';
import '../controllers/chat_providers.dart';
import '../widgets/chat/chat_user_tile.dart';
import 'nearby_devices_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUserId = ref.read(getUserIdProvider);
    if (myUserId == null) return const AuthenticationRequiredScreen();

    final chatUserIds = ref.watch(getMyFriendsIdsProvider);
    if (myUserId != 'Testing') return const TestReactionPage();
    
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: AppBar(title: const Text('الدردشات')),
      body: chatUserIds.isEmpty
          ? const Center(
              child: Text('لا يوجد لديك دردشات بعد. اضغط + لبدء الدردشة'),
            )
          : ListView.builder(
              itemCount: chatUserIds.length,
              itemBuilder: (context, index) {
                final peerId = chatUserIds[index];
                return ChatUserTile(peerId: peerId, myUserId: myUserId);
              },
            ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        child: const Icon(Icons.person_add),
        onPressed: () {
          context.pushTo(const NearbyDevicesScreen());
        },
      ),
    );
  }
}

class AuthenticationRequiredScreen extends StatelessWidget {
  const AuthenticationRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الدردشات')),
      body: Center(
        child: !Platform.isAndroid
            ? const Text('هذه الميزة متاحة فقط على أندرويد')
            : ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'يجب أن تكون مسجل الدخول حتى تستطيع الدردشة',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.pushTo(const SignInScreen());
                    },
                    child: const Text('تسجيل الدخول'),
                  ),
                ],
              ),
      ),
    );
  }
}
