import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/nearby_identity_model.dart';
import '../../controllers/chat_providers.dart';
import 'nearby_device_card.dart';
import 'no_device_widget.dart';

class NearbyDevicesList extends ConsumerWidget {
  const NearbyDevicesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(nearbyEndpointsProvider, (_, state) {});
    final endpointsAsync = ref.watch(nearbyEndpointsProvider);

    final isDiscovering = ref
        .watch(nearbyDiscoveryControllerProvider)
        .nearby
        .isDiscovering;

    if (!isDiscovering) return _DevicesListWidget(endpointsAsync.value ?? {});

    return endpointsAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
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
  final Map<String, String> endpoints;

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
          final rawName = endpoints[endpointId] ?? endpointId;
      
          final identityModel = NearbyIdentityModel.fromJson(rawName);
      
          return NearbyDeviceCard(
            endpointId: endpointId,
            identity: identityModel,
          );
        },
      ),
    );
  }
}
