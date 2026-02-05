import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NearbyDevicesAppBar extends ConsumerWidget{
  const NearbyDevicesAppBar({super.key});


  @override
  Widget build(BuildContext context,ref) {
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
           
          },
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}
