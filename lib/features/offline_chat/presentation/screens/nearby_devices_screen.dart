import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../../../../core/constants/colors/colors.dart';
import '../controllers/chat_providers.dart';
import '../controllers/nearby_discovery_controller.dart';
import '../widgets/nearby_devices/nearby_devices_appbar.dart';
import '../widgets/nearby_devices/nearby_devices_list.dart';

class NearbyDevicesScreen extends ConsumerStatefulWidget {
  const NearbyDevicesScreen({super.key});

  @override
  ConsumerState<NearbyDevicesScreen> createState() =>
      _NearbyDevicesScreenState();
}

class _NearbyDevicesScreenState extends ConsumerState<NearbyDevicesScreen> {
  final _serviceId = 'com.linknote.nearby_chat';
  final _strategy = Strategy.P2P_POINT_TO_POINT;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  NearbyDiscoveryController get nearbyController =>
      ref.read(nearbyDiscoveryControllerProvider.notifier);

  Future<void> _boot() async {
    await nearbyController.runDependencies();

    await nearbyController.beginNearbyCommunication(
      strategy: _strategy,
      serviceId: _serviceId,
    );
  }

  Future<void> _refresh() async {
     await nearbyController.restartNearbyCommunication(
      strategy: _strategy,
      serviceId: _serviceId,
    );

  }

  @override
  void deactivate() {
    ref.read(nearbyDiscoveryControllerProvider.notifier).stopAll();

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: NearbyDevicesAppBar(),
      ),
      body: RefreshIndicator(
        color: DarkColors.primary,
        onRefresh: _refresh,
        child: const CustomScrollView(slivers: [NearbyDevicesList()]),
      ),
    );
  }
}
