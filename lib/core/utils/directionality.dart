import 'package:flutter/widgets.dart';

class DirectionalityUtils {
  DirectionalityUtils._();

  static const _RTL_DETECTION_THRESHOLD = 0.40;
  static const String _LTR_CHARS =
      r'A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02B8\u0300-\u0590'
      r'\u0800-\u1FFF\u2C00-\uFB1C\uFDFE-\uFE6F\uFEFD-\uFFFF';
  static const String _RTL_CHARS = r'\u0591-\u07FF\uFB1D-\uFDFD\uFE70-\uFEFC';

  static bool _startsWithRtl(String text) {
    return RegExp('^[^$_LTR_CHARS]*[$_RTL_CHARS]').hasMatch(text);
  }

  static bool _hasAnyLtr(String text) {
    return RegExp(
      r'['
      '$_LTR_CHARS'
      r']',
    ).hasMatch(text);
  }

  static TextDirection? detectByText(String text) {
    if (text.trim().isEmpty) return null;

    var rtlCount = 0;
    var total = 0;
    var hasWeaklyLtr = false;

    for (var token in text.split(RegExp(r'\s+'))) {
      if (_startsWithRtl(token)) {
        rtlCount++;
        total++;
      } else if (RegExp(r'^http://').hasMatch(token)) {
        hasWeaklyLtr = true;
      } else if (_hasAnyLtr(token)) {
        total++;
      } else if (RegExp(r'\d').hasMatch(token)) {
        hasWeaklyLtr = true;
      }
    }

    if (total == 0) {
      return hasWeaklyLtr ? TextDirection.ltr : null;
    } else if (rtlCount > _RTL_DETECTION_THRESHOLD * total) {
      return TextDirection.rtl;
    } else {
      return TextDirection.ltr;
    }
  }
}
