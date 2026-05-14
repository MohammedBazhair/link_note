import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../controllers/nearby_providers.dart';
import '../../screens/chat_screen.dart';
import '../common/user_avatar_with_status.dart';
import 'chat_appbar.dart';

class ChatUserTile extends ConsumerWidget {
  const ChatUserTile({super.key, required this.peerId, required this.myUserId});

  final String peerId;
  final String myUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(nearbyConnectionManagerProvider);
    final identity = manager.getIdentityByUserId(peerId);

    // This tile will ONLY rebuild when this specific user's connection status changes
    final isConnected = ref.watch(isPeerConnectedProvider(peerId));

    final params = ChatParams(identity: identity, isConnected: isConnected);

    return ListTile(
      leading: UserAvatarWithStatus(params: params),
      title: Text(params.identity.displayName),
      subtitle: Text(params.isConnected ? 'متصل' : 'غير متصل'),
      onTap: () {
        context.pushTo(ChatScreen(myId: myUserId, peerId: peerId));
      },
    );
  }
}
