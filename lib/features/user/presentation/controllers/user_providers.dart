import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/providers/core_providers.dart';

final getAvatarFileProvider = FutureProvider.autoDispose.family<File, String>((
  ref,
  avatarUrl,
) {
  return DefaultCacheManager().getSingleFile(avatarUrl);
});

final isUserLoggedInProvider = Provider.autoDispose((ref) {
  final userRepository = ref.read(userRepositoryProvider);
  return userRepository.isUserLoggedIn;
});
