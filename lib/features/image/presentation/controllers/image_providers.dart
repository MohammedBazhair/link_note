import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'image_picker_controller.dart';

final imagePickerProvider = Provider((ref) => ImagePicker());

final imagePickerControllerProvider = NotifierProvider<ImagePickerController,void>(ImagePickerController.new);


