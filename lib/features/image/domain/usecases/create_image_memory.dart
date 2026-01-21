import '../../../../core/errors/result.dart';
import '../entities/image_memory.dart';
import '../repositories/image_memories_repository.dart';

class CreateImageMemory {
  const CreateImageMemory(this._repo);
  final ImageMemoriesRepository _repo;

  Future<Result<ImageMemory>> call({
    required String userId,
    required String imageFilePath,
    String? title,
    String? description,
    List<String> tags = const [],
    DateTime? memoryDate,
  }) {
    return _repo.createMemory(
      userId: userId,
      imageFilePath: imageFilePath,
      title: title,
      description: description,
      tags: tags,
      memoryDate: memoryDate,
    );
  }
}


