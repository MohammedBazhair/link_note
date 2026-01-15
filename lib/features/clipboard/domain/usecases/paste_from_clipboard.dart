import '../repositories/clipboard_repository.dart';

class PasteFromClipboard {
  PasteFromClipboard(this.repository);
  final ClipboardRepository repository;

  Future<String?> call() {
    return repository.pasteText();
  }
}
