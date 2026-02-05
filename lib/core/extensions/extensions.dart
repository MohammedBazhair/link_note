import 'dart:convert';

import 'package:flutter/material.dart';

import '../constants/external_constants/external_constants.dart';

extension ShowSnackbar on BuildContext {
  void showSnakbar(String msg) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      snackBarAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInCirc,
      ),
    );
  }
}

extension RoutesNavigators on BuildContext {
  Future<T?> pushTo<T extends Object?>(Widget screen) {
    return Navigator.push(
      this,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<T?> pushReplacementTo<T extends Object?, TO extends Object?>(
    Widget screen,
  ) {
    return Navigator.pushReplacement(
      this,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void pop<T extends Object?>([T? result]) {
    Navigator.pop(this, result);
  }
}

extension FilesSizes on num {
  double get bytesToMb => this / (1024 * 1024);
}

extension QrDataMinpulation on String {
  bool get isQrDataSafe {
    final bytes = utf8.encode(this);
    return bytes.length <= ExternalConsts.qrSafeLimitBytes;
  }
}

extension DateTimeFormats on DateTime {
 String get formattedChatTime {
    final localDate = toLocal();
    final hour = localDate.hour;
    final minute = localDate.minute;

    final ampm = hour >= 12 ? 'PM' : 'AM';
    final hourFormatted = hour % 12 == 0 ? 12 : hour % 12;
    final minuteFormatted = minute.toString().padLeft(2, '0');

    return '$hourFormatted:$minuteFormatted $ampm';
  }

}
