// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors/colors.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../user/presentation/widgets/user_avatar.dart';
import '../../domain/entities/chat_session.dart';
import '../controllers/providers.dart';
import 'chat_screen.dart';

class BluetoothDevicesScreen extends ConsumerStatefulWidget {
  const BluetoothDevicesScreen({super.key, required this.myUserId});
  final String myUserId;

  @override
  ConsumerState<BluetoothDevicesScreen> createState() =>
      _BluetoothDevicesScreenState();
}

class _BluetoothDevicesScreenState
    extends ConsumerState<BluetoothDevicesScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(bluetoothControllerProvider.notifier).checkBluetooth();
  }

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(getBoundedDevicesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('الأجهزة المرتبطة')),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        tooltip: 'فتح صفحة البلوتوث',
        child: const Icon(Icons.bluetooth_connected_sharp),
        onPressed: () {
          ref
              .read(bluetoothControllerProvider.notifier)
              .openBluetoothSettings();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Expanded(
              child: devicesAsync.when(
                data: (devices) {
                  if (devices.isEmpty) {
                    return RefreshIndicator(
                      color: DarkColors.primary,
                      onRefresh: () async {
                        ref.invalidate(getBoundedDevicesProvider);
                      },

                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height *0.70,
                          child: const Center(
                            child: Text('لا توجد أجهزة مرتبطة'),
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: DarkColors.primary,

                    onRefresh: () async {
                      ref.invalidate(getBoundedDevicesProvider);
                    },

                    child: ListView.separated(
                      itemCount: devices.length,
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return ListTile(
                          minVerticalPadding: 5,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 2,
                          ),
                          leading: const PlaceholderAvatar(),
                          title: Text(device.name),
                          subtitle: Text(
                            device.isConnected ? 'متصل' : 'غير متصل',
                          ),
                          onTap: () async {
                            final connectionManager = ref.read(
                              connectionManagerProvider,
                            );
                            final sessionManager = ref.read(
                              chatSessionManagerProvider,
                            );

                            // Establish or reuse a low-level connection.
                            await connectionManager.ensureConnection(
                              device.address,
                            );

                            // For now we treat the Bluetooth MAC address as the
                            // peer logical id. If your remote app sends a real
                            // userId via handshake, you can update this to use it.
                            final peerUserId = device.address;

                            final session = ChatSession.create(
                              myUserId: widget.myUserId,
                              peerUserId: peerUserId,
                              peerAddress: device.address,
                            );
                            sessionManager.addSession(session);

                            await context.pushTo(
                              ChatScreen(
                                peerId: peerUserId,
                                myId: widget.myUserId,
                                peerUserId: peerUserId,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () {
                  return const Center(child: CircularProgressIndicator());
                },
                error: (_, _) {
                  return const Center(child: Text('حدث خطأ'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
