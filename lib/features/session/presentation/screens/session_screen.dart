import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../user/presentation/widgets/user_avatar.dart';
import '../controllers/session_controller.dart';

enum SessionPopupOption { end }

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider).session;

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
                  context.pop();
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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Code:',
                    style: const TextStyle(
                      color: Color(0xE2FFFFFF),
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      const TextSpan(text: '    '),
                      TextSpan(
                        text: session?.sessionCode ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    // TODO: implement copy to clipboard
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
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
                      spacing: 10,
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
