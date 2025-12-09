import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class RemoteStorageService {
  Future<String> getUrlFrom({
    required String path,
    required String storageBucket,
  });

  Future<String> uploadFile({
    required String filePath,
    required String storageBucket,
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
  Future<String> getUrlFrom({
    required String path,
    required String storageBucket,
  }) {
    return _storage.from(storageBucket).createSignedUrl(path, 3600);
  }

  @override
  Future<String> uploadFile({
    required String filePath,
    required String storageBucket,
  }) async {
    final filename = p.basename(filePath);
    final file = File(filePath);
    final resultPath = 'public/$filename';

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
