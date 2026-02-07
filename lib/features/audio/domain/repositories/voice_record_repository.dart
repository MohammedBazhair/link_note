
abstract class VoiceRecordRepository {
  Future<void> startRecording({required String path});
  Future<String?> stopRecording();
}
