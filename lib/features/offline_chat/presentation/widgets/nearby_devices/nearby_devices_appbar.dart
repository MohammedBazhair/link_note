import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/chat_providers.dart';
import 'form_local_name.dart';

class NearbyDevicesAppBar extends ConsumerStatefulWidget {
  const NearbyDevicesAppBar({super.key});

  @override
  ConsumerState<NearbyDevicesAppBar> createState() =>
      _NearbyDevicesAppBarState();
}

class _NearbyDevicesAppBarState extends ConsumerState<NearbyDevicesAppBar> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final initialName = ref.read(nearbyDisplayNameProvider);
    _nameController.text = initialName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('أجهزة قريبة'),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
      actions: [
        PopupMenuButton(
          menuPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'change_name',
              child: Text('تغيير الاسم'),
            ),
          ],
          onSelected: (value) {
            if (value == 'change_name') {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return FormLocalName(nameController: _nameController);
                },
              );
            }
          },
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}
