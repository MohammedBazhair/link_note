import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class RemoteStorageService {
  String getUrlFrom({required String path, required String storageBucket});

  Future<String> uploadFile({
    required String filePath,
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
  }) async {
    final filename = p.basename(filePath);
    final name = filename.split('.').first;
    final fileExtension = filename.split('.').last;
    final resultName = '$name.$fileExtension';
    final file = File(filePath);
    final resultPath = 'public/$resultName';
    await _storage
        .from(storageBucket)
        .upload(resultPath, file, fileOptions: const FileOptions(upsert: true));

    return resultPath;
  }
}
