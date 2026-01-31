abstract class NearbyState {
  NearbyState({required this.nearby});

  final NearbyData nearby;
}

class NearbyInitialState extends NearbyState {
  NearbyInitialState({required super.nearby});
}

class NearbyUpdatedState extends NearbyState {
  NearbyUpdatedState({required super.nearby});
}

class NearbyeErrorState extends NearbyState {
  NearbyeErrorState({required super.nearby, required this.message});
  final String message;
}



class NearbyData {
  const NearbyData({this.isAdvertising = false, this.isDiscovering = false});

  final bool isAdvertising;
  final bool isDiscovering;

  NearbyData copyWith({bool? isAdvertising, bool? isDiscovering}) {
    return NearbyData(
      isAdvertising: isAdvertising ?? this.isAdvertising,
      isDiscovering: isDiscovering ?? this.isDiscovering,
    );
  }
}
