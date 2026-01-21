import '../../../../core/errors/result.dart';
import '../entities/image_memory.dart';
import '../repositories/image_memories_repository.dart';

class UpdateImageMemory {
  const UpdateImageMemory(this._repo);
  final ImageMemoriesRepository _repo;

  Future<Result<void>> call(ImageMemory memory) {
    return _repo.updateMemory(memory);
  }
}


