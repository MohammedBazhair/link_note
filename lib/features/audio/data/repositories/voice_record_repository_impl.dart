import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/internal_constants/log.dart';
import '../../domain/repositories/voice_record_repository.dart';
import '../datasources/voice_record_datasource.dart';

class VoiceRecordRepositoryImpl implements VoiceRecordRepository {
  VoiceRecordRepositoryImpl(this._dataSource);
  final VoiceRecordDataSource _dataSource;

  @override
  Future<void> startRecording({required String path}) async {
    try {
      await _dataSource.start(path: path);
    } catch (e) {
      Logger.log(error: e);
    }
  }

  @override
  Future<String?> stopRecording() {
    return _dataSource.stop();
  }

  @override
  Future<bool> hasPermissions([bool request = true]) async {
    if (request) await Permission.microphone.request();
    final status = await Permission.microphone.status;
    Logger.log(message: 'status $status');
    return status.isGranted;
  }
}
