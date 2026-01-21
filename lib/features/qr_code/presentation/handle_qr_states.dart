import 'package:flutter/material.dart';

import '../../../core/extensions/extensions.dart';
import 'controller/qr_state.dart';

void handleQrStates(BuildContext context, QrState state) {
  switch (state) {
    case QrInitialState():
    case QrScanningState():
    case QrCameraUpdatedState():
      break;
    case QrImageSavedState(:final imageName):
      context.showSnakbar('تم حفظ الصورة في المعرض باسم $imageName');
    case QrScannedDoneState(:final message, :final scannedRawResult):
      context.showSnakbar(message);
      context.pop<String>(scannedRawResult);
    case QrErrorState(:final message):
      context.showSnakbar(message);
  }
}
