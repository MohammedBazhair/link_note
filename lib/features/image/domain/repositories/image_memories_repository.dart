import '../../../../core/errors/result.dart';
import '../entities/image_memory.dart';

abstract interface class ImageMemoriesRepository {
  Stream<List<ImageMemory>> watchMemories({required String userId});

  Future<Result<ImageMemory>> createMemory({
    required String userId,
    required String imageFilePath,
    String? title,
    String? description,
    List<String> tags = const [],
    DateTime? memoryDate,
  });

  Future<Result<void>> updateMemory(ImageMemory memory);

  Future<Result<void>> deleteMemory(ImageMemory memory);

  Future<Result<String>> getSignedImageUrl({
    required String imagePath,
    int expiresInSeconds = 60 * 30,
  });
}


