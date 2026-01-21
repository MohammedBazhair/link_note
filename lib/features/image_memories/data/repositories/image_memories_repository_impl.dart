import 'package:uuid/uuid.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/image_memory.dart';
import '../../domain/repositories/image_memories_repository.dart';
import '../datasources/image_memories_remote_data_source.dart';
import '../models/image_memory_model.dart';

class ImageMemoriesRepositoryImpl implements ImageMemoriesRepository {
  ImageMemoriesRepositoryImpl(this._remote, this._uuid);

  final ImageMemoriesRemoteDataSource _remote;
  final Uuid _uuid;

  @override
  Stream<List<ImageMemory>> watchMemories({required String userId}) {
    return _remote.watchMemories(userId: userId);
  }

  @override
  Future<Result<ImageMemory>> createMemory({
    required String userId,
    required String imageFilePath,
    String? title,
    String? description,
    List<String> tags = const [],
    DateTime? memoryDate,
  }) async {
    final imageId = _uuid.v4();
    final res = await _remote.createMemory(
      userId: userId,
      imageFilePath: imageFilePath,
      imageId: imageId,
      title: title,
      description: description,
      tags: tags,
      memoryDate: memoryDate,
    );
    if (res.hasError) return Result.error(res.errorMessage);
    return Result.ok(res.value);
  }

  @override
  Future<Result<void>> updateMemory(ImageMemory memory) {
    final model = ImageMemoryModel(
      id: memory.id,
      userId: memory.userId,
      imagePath: memory.imagePath,
      title: memory.title,
      description: memory.description,
      tags: memory.tags,
      memoryDate: memory.memoryDate,
      createdAt: memory.createdAt,
    );
    return _remote.updateMemory(model);
  }

  @override
  Future<Result<void>> deleteMemory(ImageMemory memory) {
    final model = ImageMemoryModel(
      id: memory.id,
      userId: memory.userId,
      imagePath: memory.imagePath,
      title: memory.title,
      description: memory.description,
      tags: memory.tags,
      memoryDate: memory.memoryDate,
      createdAt: memory.createdAt,
    );
    return _remote.deleteMemory(model);
  }

  @override
  Future<Result<String>> getSignedImageUrl({
    required String imagePath,
    int expiresInSeconds = 60 * 30,
  }) {
    return _remote.createSignedUrl(
      imagePath: imagePath,
      expiresInSeconds: expiresInSeconds,
    );
  }
}


