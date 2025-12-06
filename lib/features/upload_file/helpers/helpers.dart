import 'package:image_picker/image_picker.dart';

Future<XFile?> uploadImage([ImageSource source = ImageSource.gallery]) async {
  final file = await ImagePicker().pickImage(source: source);
  return file;
}
