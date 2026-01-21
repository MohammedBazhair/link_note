import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/features/database/remote/remote_database_service.dart';
import '../models/image_memory_model.dart';

abstract interface class ImageMemoriesRemoteDataSource {
  Stream<List<ImageMemoryModel>> watchMemories({required String userId});

  Future<Result<ImageMemoryModel>> createMemory({
    required String userId,
    required String imageFilePath,
    required String imageId,
    String? title,
    String? description,
    List<String> tags = const [],
    DateTime? memoryDate,
  });

  Future<Result<void>> updateMemory(ImageMemoryModel memory);

  Future<Result<void>> deleteMemory(ImageMemoryModel memory);

  Future<Result<String>> createSignedUrl({
    required String imagePath,
    int expiresInSeconds = 60 * 30,
  });
}

class ImageMemoriesRemoteDataSourceImpl implements ImageMemoriesRemoteDataSource {
  ImageMemoriesRemoteDataSourceImpl(
    this._db,
    this._client,
  );

  static const String tableName = 'image_memories';
  static const String bucketName = 'memories_images';

  final RemoteDatabaseService _db;
  final SupabaseClient _client;

  @override
  Stream<List<ImageMemoryModel>> watchMemories({required String userId}) {
    final stream = _db.readRowsRealTime(
      table: tableName,
      primaryKey: const ['id'],
      column: 'user_id',
      value: userId,
    );

    return stream.map((rows) {
      final list = (rows as List)
          .cast<Map<String, dynamic>>()
          .map(ImageMemoryModel.fromMap)
          .toList();
      // Chronological ordering (newest first)
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<Result<ImageMemoryModel>> createMemory({
    required String userId,
    required String imageFilePath,
    required String imageId,
    String? title,
    String? description,
    List<String> tags = const [],
    DateTime? memoryDate,
  }) async {
    try {
      final imagePath = '$userId/$imageId.jpg';
      final file = File(imageFilePath);
      await _client.storage.from(bucketName).upload(
            imagePath,
            file,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
            ),
          );

      final model = ImageMemoryModel(
        id: imageId,
        userId: userId,
        imagePath: imagePath,
        title: title,
        description: description,
        tags: tags,
        memoryDate: (memoryDate ?? DateTime.now()).toLocal(),
        createdAt: DateTime.now().toUtc(),
      );

      final inserted = await _db.insertRow(map: model.toInsertMap(), table: tableName);
      return Result.ok(ImageMemoryModel.fromMap(inserted));
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  @override
  Future<Result<void>> updateMemory(ImageMemoryModel memory) async {
    try {
      await _db.update(
        updated: memory.toUpdateMap(),
        id: memory.id,
        column: 'id',
        table: tableName,
      );
      return Result.ok(null);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  @override
  Future<Result<void>> deleteMemory(ImageMemoryModel memory) async {
    try {
      // Optimistically delete row first (RLS will prevent cross-user access).
      await _db.delete(id: memory.id, column: 'id', table: tableName);

      // Then delete storage object (best-effort).
      try {
        await _client.storage.from(bucketName).remove([memory.imagePath]);
      } catch (_) {}

      return Result.ok(null);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  @override
  Future<Result<String>> createSignedUrl({
    required String imagePath,
    int expiresInSeconds = 60 * 30,
  }) async {
    try {
      final url = await _client.storage.from(bucketName).createSignedUrl(
            imagePath,
            expiresInSeconds,
          );
      return Result.ok(url);
    } catch (e) {
      return Result.error(e.toString());
    }
  }
}


