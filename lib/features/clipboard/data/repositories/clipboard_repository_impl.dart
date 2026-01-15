import 'package:flutter/services.dart';

import '../../domain/repositories/clipboard_repository.dart';

class ClipboardRepositoryImpl implements ClipboardRepository {
  ClipboardRepositoryImpl();

  @override
  Future<void> copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Future<String?> pasteText() async {
    if (!await Clipboard.hasStrings()) return null;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
