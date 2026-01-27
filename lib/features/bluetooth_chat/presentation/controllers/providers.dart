import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/providers/core_providers.dart';
import '../../data/bluetooth/bluetooth_service.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/message.dart';
import 'chat_controller.dart';

final chatControllerProvider = NotifierProvider<ChatController, List<Message>>(
  () {
    return ChatController();
  },
);

final bluetoothServiceProvider = Provider((ref) {
  return BluetoothService();
});

final chatRepository = Provider((ref) {
  final _service = ref.watch(bluetoothServiceProvider);
  final myUserId = ref.watch(userRepositoryProvider).currentUser!.id;
  return ChatRepositoryImpl(_service, myUserId: myUserId);
});
