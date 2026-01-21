import '../../../../core/errors/result.dart';
import '../entities/image_memory.dart';
import '../repositories/image_memories_repository.dart';

class DeleteImageMemory {
  const DeleteImageMemory(this._repo);
  final ImageMemoriesRepository _repo;

  Future<Result<void>> call(ImageMemory memory) {
    return _repo.deleteMemory(memory);
  }
}


