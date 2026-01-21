import '../../domain/entities/scanner_state.dart';

sealed class QrState {
  QrState({required this.scannerState});

  final ScannerState scannerState;
}

class QrInitialState extends QrState {
  QrInitialState({required super.scannerState});
}

class QrScanningState extends QrState {
  QrScanningState({required super.scannerState});
}

class QrCameraUpdatedState extends QrState {
  QrCameraUpdatedState({required super.scannerState});
}

class QrScannedDoneState extends QrState {
  QrScannedDoneState({
    required super.scannerState,
    required this.scannedRawResult,
    required this.message,
  });
  final String message;
  final String scannedRawResult;
}

class QrImageSavedState extends QrState {
  QrImageSavedState({required super.scannerState,required this.imageName});
  final String imageName;
}

class QrErrorState extends QrState {
  QrErrorState({required super.scannerState, required this.message});
  final String message;
}
