import 'package:link_note/core/errors/exceptions.dart';

class AiResponseModel {
  AiResponseModel({this.resultText, this.error});

  factory AiResponseModel.fromMap(Map<String, dynamic> map) {
    try {
      final error = map['message'] as String?;
      if (error != null) throw AiServiceException(error);

      final choices = map['choices'];

      if (choices is! List || choices.isEmpty) {
        throw const AiServiceException('Empty response');
      }

      final firstChoice = choices.first;

      final content = firstChoice?['message']?['content'];

      if (content == null) {
        throw const AiServiceException('Missing content');
      }

      return AiResponseModel(resultText: content.toString());
    } catch (e) {
      return AiResponseModel(error: _mapError(e.toString()));
    }
  }

  static String _mapError(String msg) {
    if (msg.contains('No active')) {
      return 'الخدمة متوقفة حاليا ولا يمكنك استعمال AI';
    }
    if (msg.contains('Empty response')) {
      return 'لم يتم استلام أي رد من الخدمة';
    }
    if (msg.contains('Missing content')) {
      return 'الرد غير مكتمل من الخدمة';
    }
    return 'حدث خطأ غير متوقع أثناء الاتصال بالخدمة';
  }

  final String? resultText;
  final String? error;
}
