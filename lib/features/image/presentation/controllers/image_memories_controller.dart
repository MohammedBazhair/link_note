import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/image_memory.dart';
import '../../domain/usecases/create_image_memory.dart';
import '../../domain/usecases/delete_image_memory.dart';
import '../../domain/usecases/update_image_memory.dart';
import 'image_memories_providers.dart';

class ImageMemoriesController extends AsyncNotifier<List<ImageMemory>> {

  @override
  Future<List<ImageMemory>> build() async {
    _create = ref.read(createImageMemoryUseCaseProvider);
    _update = ref.read(updateImageMemoryUseCaseProvider);
    _delete = ref.read(deleteImageMemoryUseCaseProvider);

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return [];

    // Keep state synced to realtime stream.
    final stream = ref
        .read(imageMemoriesRepositoryProvider)
        .watchMemories(userId: userId);
    final sub = stream.listen(
      (value) => state = AsyncData(value),
      onError: (e, _) => state = AsyncError(e, StackTrace.current),
    );
    ref.onDispose(sub.cancel);

    return stream.first;
  }

  Future<Result<ImageMemory>> create({
    required String imageFilePath,
    String? title,
    String? description,
    List<String> tags = const [],
    DateTime? memoryDate,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return Result.error('User not logged in');
    final res = await _create(
      userId: userId,
      imageFilePath: imageFilePath,
      title: title,
      description: description,
      tags: tags,
      memoryDate: memoryDate,
    );
    return res;
  }

  Future<Result<void>> updateMemory(ImageMemory memory) {
    return _update(memory);
  }

  Future<Result<void>> deleteMemory(ImageMemory memory) async {
    final current = state.asData?.value ?? const <ImageMemory>[];
    // Optimistic: remove immediately; if fails, restore.
    state = AsyncData(current.where((m) => m.id != memory.id).toList());
    final res = await _delete(memory);
    if (res.hasError) {
      state = AsyncData(current);
    }
    return res;
  }
}
