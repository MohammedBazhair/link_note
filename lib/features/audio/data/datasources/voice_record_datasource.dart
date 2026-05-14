
import 'package:record/record.dart';

class VoiceRecordDataSource {
  VoiceRecordDataSource(this._record);

  final AudioRecorder _record;

  Future<bool> hasPermissions([bool request = true])  {
   
    return _record.hasPermission(request: request);
  }

  RecordConfig get _recordConfig => const RecordConfig(
    encoder: AudioEncoder.opus,
    bitRate: 64000,
    sampleRate: 48000,
  );

  Future<void> start({required String path, RecordConfig? config}) async {
    await _record.start(config ?? _recordConfig, path: path);
  }

  /// Returns the output path if any.
  Future<String?> stop() => _record.stop();
}
