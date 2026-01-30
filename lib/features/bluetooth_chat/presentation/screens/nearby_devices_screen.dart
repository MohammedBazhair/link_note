import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../../../../core/constants/colors/colors.dart';
import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/extensions/extensions.dart';
import '../../data/datasource/nearby_service.dart';
import '../../data/models/nearby_identity_model.dart';
import '../../domain/entities/chat_session.dart';
import '../controllers/chat_providers.dart';
import '../widgets/user_avatar_with_status.dart';
import 'chat_screen.dart';

class NearbyDevicesScreen extends ConsumerStatefulWidget {
  const NearbyDevicesScreen({super.key, required this.myUserId});
  final String myUserId;

  @override
  ConsumerState<NearbyDevicesScreen> createState() =>
      _NearbyDevicesScreenState();
}

class _NearbyDevicesScreenState extends ConsumerState<NearbyDevicesScreen> {
  static const _serviceId = 'com.linknote.nearby_chat';
  static const _strategy = Strategy.P2P_POINT_TO_POINT;

  String? _error;
  bool _loading = false;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final initialName = ref.read(nearbyDisplayNameProvider);
    _nameController = TextEditingController(text: initialName);
    _boot();
  }

  Future<void> _boot() async {
    setState(() {
      _loading = true;
    });
    final result = await NearbyConnectionManager.runDependencies();
    if (result.hasError) {
      setState(() {
        _error = result.errorMessage;
        _loading = false;
      });
      return;
    }

    try {
      await ref
          .read(nearbyDiscoveryControllerProvider.notifier)
          .beginNearbyCommunication(strategy: _strategy, serviceId: _serviceId);
    } catch (e) {
      if (!mounted) return;
      Logger.log(error: e);
      setState(() {
        _error = 'فشل تشغيل Nearby: $e';
        _loading = false;
      });
      return;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
     await ref.read(nearbyDiscoveryControllerProvider.notifier).restartNearbyCommunication(
      strategy: _strategy,
      serviceId: _serviceId,
     );
  
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    ref.read(nearbyDiscoveryControllerProvider.notifier).stopAll();

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final manager = ref.watch(connectionManagerProvider);
    final endpointsAsync = ref.watch(nearbyEndpointsProvider);
    final connectedAsync = ref.watch(nearbyConnectedEndpointsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أجهزة قريبة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'إعادة البحث',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: _error != null
            ? Center(child: Text(_error!))
            : Column(
                spacing: 22,
                children: [
                  const Text(
                    'افتح نفس الصفحة على الهاتف الآخر. سيتم اكتشاف الأجهزة القريبة هنا.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: DarkColors.secondFont,
                      fontSize: 13,
                    ),
                  ),
                  // Custom Name Section
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'ادخل اسمك ليظهر للآخرين',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_nameController.text.trim().isEmpty) return;
                          ref
                              .read(nearbyDisplayNameProvider.notifier)
                              .update(_nameController.text.trim());
                          _refresh();
                        },
                        child: const Text('تحديث'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: endpointsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('خطأ: $err')),
                      data: (endpoints) {
                        if (endpoints.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bluetooth_searching,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text('لا توجد أجهزة قريبة الآن'),
                                Text(
                                  'تأكد من تفعيل البلوتوث والموقع',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: endpoints.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final endpointId = endpoints.keys.elementAt(index);
                            final rawName = endpoints[endpointId] ?? endpointId;

                            // Identity is JSON
                            final identityModel = NearbyIdentityModel.fromJson(
                              rawName,
                            );
                            final peerUuid = identityModel.uuid;
                            final name = identityModel.displayName;

                            final isIdentified = name != endpointId;
                            final connected =
                                connectedAsync.value?.contains(endpointId) ??
                                false;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 4,
                              ),
                              title: Text(
                                isIdentified ? name : 'جهاز غير معروف',
                              ),
                              leading: UserAvatarWithStatus(
                                connected: connected,
                              ),
                              subtitle: Text(
                                connected
                                    ? 'متصل'
                                    : !isIdentified
                                    ? 'جاري التعرف على الجهاز...'
                                    : 'اضغط للاتصال',
                              ),
                              onTap: !isIdentified
                                  ? null
                                  : () async {
                                      if (!connected) {
                                        try {
                                          await manager.connect(endpointId);
                                        } catch (e) {
                                          if (!mounted) return;
                                          context.showSnakbar('فشل الاتصال');
                                          return;
                                        }
                                      }

                                      final sessionManager = ref.read(
                                        chatSessionManagerProvider,
                                      );

                                      // peerId must be the UUID for stable chatId filtering
                                      final session = ChatSession.create(
                                        myUserId: widget.myUserId,
                                        peerUserId: peerUuid,
                                        peerAddress: endpointId,
                                      );
                                      sessionManager.addSession(session);

                                      if (!mounted) return;
                                      await context.pushTo(
                                        ChatScreen(
                                          peerId: peerUuid,
                                          myId: widget.myUserId,
                                          peerUserId: peerUuid,
                                        ),
                                      );
                                    },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
