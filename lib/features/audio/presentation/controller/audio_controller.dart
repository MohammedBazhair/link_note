import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/assets/app_assets.dart';
import '../../domain/repositories/audio_repository.dart';
import 'audio_provider.dart';

class AudioController extends Notifier<void> {
 late final AudioRepository repository;

  @override
  void build() {
    repository= ref.read(audioRepositoryProvider);
  }


  Future<void> playSound(String assetPath) {
    return repository.play(assetPath);
  }

  Future<void> playBell() {
    return repository.play(Assets.soundsBell);
  }

  
}
