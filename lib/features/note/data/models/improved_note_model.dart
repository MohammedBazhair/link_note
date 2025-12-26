import '../../domain/entities/ai_response.dart';

class AiResponseModel extends AiResponseEntity {
  const AiResponseModel({required super.content});

  factory AiResponseModel.empty() {
    return const AiResponseModel(content: '');
  }

  factory AiResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      return AiResponseModel(
        content: json['choices'][0]['message']['content'] as String,
      );
    } catch (e) {
      return AiResponseModel.empty();
    }
  }
}
