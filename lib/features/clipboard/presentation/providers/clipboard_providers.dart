import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/clipboard_repository_impl.dart';
import '../../domain/repositories/clipboard_repository.dart';
import '../../domain/usecases/copy_to_clipboard.dart';
import '../../domain/usecases/paste_from_clipboard.dart';

final _clipboardRepoProvider = Provider.autoDispose<ClipboardRepository>((ref) {
  return ClipboardRepositoryImpl();
});

final clipboardControllerProvider = Provider.autoDispose((ref) {
  final repo = ref.watch(_clipboardRepoProvider);
  return ClipboardController(repo);
});

class ClipboardController extends Notifier<void> {
  ClipboardController(this.repository);

  final ClipboardRepository repository;
  @override
  void build() {}

  Future<void> copyToClipboard(String text) async {
    await CopyToClipboard(repository)(text);
  }

  Future<String?> pasteText() {
    return PasteFromClipboard(repository)();
  }
}
