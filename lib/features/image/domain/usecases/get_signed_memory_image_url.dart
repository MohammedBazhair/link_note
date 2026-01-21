import '../../../../core/errors/result.dart';
import '../repositories/image_memories_repository.dart';

class GetSignedMemoryImageUrl {
  const GetSignedMemoryImageUrl(this._repo);
  final ImageMemoriesRepository _repo;

  Future<Result<String>> call({
    required String imagePath,
    int expiresInSeconds = 60 * 30,
  }) {
    return _repo.getSignedImageUrl(
      imagePath: imagePath,
      expiresInSeconds: expiresInSeconds,
    );
  }
}


