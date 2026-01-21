

class ScannerState {
  ScannerState({
    this.isFlashOn = false,
    this.isFrontCamera = false,
    this.canScan = true,
  });

  bool isFlashOn;
  bool isFrontCamera;
  bool canScan;

  ScannerState copyWith({bool? isFlashOn, bool? isFrontCamera, bool? canScan}) {
    return ScannerState(
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      canScan: canScan ?? this.canScan,
    );
  }
}

