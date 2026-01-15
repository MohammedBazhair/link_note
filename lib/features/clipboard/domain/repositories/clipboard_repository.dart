abstract class ClipboardRepository {
  Future<void> copyText(String text);
  Future<String?> pasteText();
}
