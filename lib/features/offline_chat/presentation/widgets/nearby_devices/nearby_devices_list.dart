import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/colors/colors.dart';
import '../../../domain/entities/nearby_identity.dart';
import '../../controllers/chat_providers.dart';
import '../../controllers/nearby_providers.dart';
import 'nearby_device_card.dart';
import 'no_device_widget.dart';

class NearbyDevicesList extends ConsumerWidget {
  const NearbyDevicesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final endpointsAsync = ref.watch(allKnownEndpointsProvider);

    final isDiscovering = ref
        .watch(nearbyDiscoveryControllerProvider)
        .nearby
        .isDiscovering;

    if (!isDiscovering) return _DevicesListWidget(endpointsAsync.value ?? {});

    return endpointsAsync.when(
      loading: () => const SliverFillRemaining(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            CircularProgressIndicator(),
            Text(
              'جاري البحث عن الأجهزة القريبة...',
              style: TextStyle(color: DarkColors.secondFont, fontSize: 11),
            ),
          ],
        ),
      ),
      error: (err, _) =>
          SliverFillRemaining(child: Center(child: Text('خطأ: $err'))),
      data: (endpoints) {
        return _DevicesListWidget(endpoints);
      },
    );
  }
}

class _DevicesListWidget extends StatelessWidget {
  const _DevicesListWidget(this.endpoints);
  final Map<String, NearbyIdentity> endpoints;

  @override
  Widget build(BuildContext context) {
    if (endpoints.isEmpty) {
      return const SliverFillRemaining(child: NoDevicesWidget());
    }

    return SliverPadding(
      padding: const EdgeInsets.all(24),

      sliver: SliverList.separated(
        itemCount: endpoints.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final endpointId = endpoints.keys.elementAt(index);
          final identity = endpoints[endpointId];

          return NearbyDeviceCard(endpointId: endpointId, identity: identity!);
        },
      ),
    );
  }
}
