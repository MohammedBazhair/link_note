import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/cipher_service.dart';

abstract interface class RemoteStorageService {
  String getUrlFrom({required String path, required String storageBucket});

  Future<String> uploadFile({
    required String filePath,
    required String storageBucket,
    required String userId,
  });

  Future<void> deleteAllFilesInFolder({
    required String folderPath,
    required String storageBucket,
  });
}

class RemoteStorageServiceImpl implements RemoteStorageService {
  RemoteStorageServiceImpl(this._storage);
  final SupabaseStorageClient _storage;

  @override
  String getUrlFrom({required String path, required String storageBucket}) {
    return _storage.from(storageBucket).getPublicUrl(path);
  }

  @override
  Future<String> uploadFile({
    required String filePath,
    required String storageBucket,
    required String userId,
  }) async {
    final filename = p.basename(filePath);
    final file = File(filePath);
    final folderName = CipherService.encrypt(userId);
    final resultPath = 'public/$folderName/$filename';

    await _storage
        .from(storageBucket)
        .upload(resultPath, file, fileOptions: const FileOptions(upsert: true));

    return resultPath;
  }

  @override
  Future<void> deleteAllFilesInFolder({
    required String folderPath,
    required String storageBucket,
  }) async {
    final files = await _storage.from(storageBucket).list(path: folderPath);
    if (files.isEmpty) return;

    final paths = files.map((f) => '$folderPath${f.name}').toList();
    await _storage.from(storageBucket).remove(paths);
  }
}
