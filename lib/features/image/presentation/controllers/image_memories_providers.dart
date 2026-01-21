import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/presentation/providers/core_providers.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../../data/datasources/image_memories_remote_data_source.dart';
import '../../data/repositories/image_memories_repository_impl.dart';
import '../../domain/entities/image_memory.dart';
import '../../domain/repositories/image_memories_repository.dart';
import '../../domain/usecases/create_image_memory.dart';
import '../../domain/usecases/delete_image_memory.dart';
import '../../domain/usecases/get_signed_memory_image_url.dart';
import '../../domain/usecases/update_image_memory.dart';
import 'image_memories_controller.dart';

final isInImageMemoriesScreen = StateProvider((_) => false);

final _uuidProvider = Provider((_) => const Uuid());

final imageMemoriesRemoteDataSourceProvider = Provider<ImageMemoriesRemoteDataSource>((ref) {
  final db = ref.read(remoteDatabaseServiceProvider);
  final client = ref.read(supabaseProvider).client;
  return ImageMemoriesRemoteDataSourceImpl(db, client);
});

final imageMemoriesRepositoryProvider = Provider<ImageMemoriesRepository>((ref) {
  final remote = ref.read(imageMemoriesRemoteDataSourceProvider);
  final uuid = ref.read(_uuidProvider);
  return ImageMemoriesRepositoryImpl(remote, uuid);
});

final createImageMemoryUseCaseProvider = Provider((ref) {
  final repo = ref.read(imageMemoriesRepositoryProvider);
  return CreateImageMemory(repo);
});

final updateImageMemoryUseCaseProvider = Provider((ref) {
  final repo = ref.read(imageMemoriesRepositoryProvider);
  return UpdateImageMemory(repo);
});

final deleteImageMemoryUseCaseProvider = Provider((ref) {
  final repo = ref.read(imageMemoriesRepositoryProvider);
  return DeleteImageMemory(repo);
});

final getSignedMemoryImageUrlUseCaseProvider = Provider((ref) {
  final repo = ref.read(imageMemoriesRepositoryProvider);
  return GetSignedMemoryImageUrl(repo);
});

final imageMemoriesControllerProvider =
    AsyncNotifierProvider<ImageMemoriesController, List<ImageMemory>>(
  ImageMemoriesController.new,
);

final signedMemoryImageUrlProvider = FutureProvider.autoDispose.family<String, String>((
  ref,
  imagePath,
) async {
  final uc = ref.read(getSignedMemoryImageUrlUseCaseProvider);
  final res = await uc(imagePath: imagePath);
  if (res.hasError) throw Exception(res.errorMessage);
  return res.value!;
});

final _userControllerProvider = Provider<UserController>((ref) {
  return ref.read(userControllerProvider.notifier);
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.read(_userControllerProvider).currentUser?.id;
});


