import 'package:flutter/foundation.dart';

class Logger {
  Logger._();

  static void log({String? message, Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) return;
    debugPrint('------------------[LOGGER]------------------');
    debugPrint(message);
    debugPrint(error.toString());
    debugPrint(stackTrace.toString());
  }
}
