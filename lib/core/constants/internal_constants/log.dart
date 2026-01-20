import 'package:flutter/foundation.dart';

class Logger {
  Logger._();

  static void log({String? message, Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) return;
    debugPrint('------------------[LOGGER]------------------');
   if(message!=null) debugPrint(message);
    if(error!=null) debugPrint(error.toString());
    if(stackTrace!=null) debugPrint(stackTrace.toString());
  }
}
