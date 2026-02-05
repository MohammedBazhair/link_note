import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../user/presentation/controllers/user_providers.dart';
import '../../../domain/entities/chat_session.dart';
import '../../../domain/entities/nearby_identity.dart';
import '../../controllers/chat_providers.dart';
import '../../controllers/nearby_providers.dart';
import '../../screens/chat_screen.dart';
import '../chat/chat_appbar.dart';
import '../common/user_avatar_with_status.dart';

class NearbyDeviceCard extends ConsumerWidget {
  const NearbyDeviceCard({
    super.key,
    required this.endpointId,
    required this.identity,
  });

  final NearbyIdentity identity;
  final String endpointId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // REFIX: Watch the stream provider to make the UI reactive to connection changes
    final connectedEndpoints =
        ref.watch(connectedEndpointsProvider).value ?? {};
    final connected = connectedEndpoints.contains(endpointId);

    final myUserId = ref.read(getUserIdProvider)!;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      title: Text(identity.displayName),
      leading: UserAvatarWithStatus(params: ChatParams(identity: identity, isConnected: connected),),
      subtitle: Text(connected ? 'متصل' : 'اضغط للاتصال'),
      onTap: () async {
        if (!connected) {
          try {
            await ref.read(nearbyConnectionManagerProvider).connect(endpointId);
          } catch (e) {
            context.showSnakbar('فشل الاتصال');
            return;
          }
        }

        final sessionManager = ref.read(chatSessionManagerProvider);

        // peerId must be the UUID for stable chatId filtering
        final session = ChatSession.create(
          myUserId: myUserId,
          peerUserId: identity.uuid,
          peerAddress: endpointId,
        );
        sessionManager.addSession(session);

        await context.pushTo(ChatScreen(peerId: identity.uuid, myId: myUserId));
      },
    );
  }
}
