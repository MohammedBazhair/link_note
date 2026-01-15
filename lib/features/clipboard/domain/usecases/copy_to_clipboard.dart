import '../repositories/clipboard_repository.dart';

class CopyToClipboard {
  CopyToClipboard(this.repository);
  final ClipboardRepository repository;

  Future<void> call(String text) {
    return repository.copyText(text);
  }
}
