import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../user/presentation/controllers/user_controller.dart';
import '../../../user/presentation/widgets/user_avatar.dart';
import '../controllers/session_controller.dart';

enum SessionPopupOption { end }

class SessionPage extends ConsumerWidget {
  const SessionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider).session;
    final profile = ref.read(userControllerProvider).profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Title'),
        actions: [
          PopupMenuButton(
            onSelected: (option) async {
              final controller = ref.read(sessionControllerProvider.notifier);
              switch (option) {
                case SessionPopupOption.end:
                  await controller.endSession();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: SessionPopupOption.end,
                child: Text('End Session'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: AvatarWidget(profile),
            title: Text('Code: ${session?.sessionCode ?? ''}'),
            trailing: ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
              onPressed: () {
                // TODO: implement copy to clipboard
              },
            ),
          ),
          const Divider(),

          SizedBox(
            height: 100,
            child: Consumer(
              builder: (_, ref, __) {
                final members = ref.watch(sessionControllerProvider).members;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members.elementAt(index);

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PlaceholderAvatar(),
                        Text(member.role.name),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
