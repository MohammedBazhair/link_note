import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getAvatarFileProvider = FutureProvider.autoDispose.family<File, String>((
  ref,
  avatarUrl,
) {
 return DefaultCacheManager().getSingleFile(avatarUrl);
});
