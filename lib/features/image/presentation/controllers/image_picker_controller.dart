import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'image_providers.dart';

class ImagePickerController extends Notifier<void> {
  @override
  void build() {}

  Future<String?> pickImage([ImageSource source = ImageSource.gallery]) async {
    final picker = ref.read(imagePickerProvider);

    final image = await picker.pickImage(source: source);
    return image?.path;
  }
}
