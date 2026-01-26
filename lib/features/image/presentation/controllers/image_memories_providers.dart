import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/presentation/providers/core_providers.dart';
import '../../data/datasources/image_memories_remote_data_source.dart';
import '../../data/repositories/image_memories_repository_impl.dart';
import '../../domain/repositories/image_memories_repository.dart';

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


