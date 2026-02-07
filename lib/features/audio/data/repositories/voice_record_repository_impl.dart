import '../../../../core/constants/internal_constants/log.dart';
import '../../domain/repositories/voice_record_repository.dart';
import '../datasources/voice_record_datasource.dart';

class VoiceRecordRepositoryImpl implements VoiceRecordRepository {
  VoiceRecordRepositoryImpl(this.dataSource);
  final VoiceRecordDataSource dataSource;

  @override
  Future<void> startRecording({required String path}) async {
    try {
      await dataSource.start(path: path);
    } catch (e) {
      Logger.log(error: e);
    }
  }

  @override
  Future<String?> stopRecording() {
    return dataSource.stop();
  }
}
