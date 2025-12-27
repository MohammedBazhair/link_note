import '../../domain/entities/ai_response.dart';

class AiResponseModel extends AiResponseEntity {
  const AiResponseModel({required super.text});

  factory AiResponseModel.empty() {
    return const AiResponseModel(text: '');
  }

  factory AiResponseModel.fromJson(Map<String, dynamic> json) {
    return AiResponseModel(
      text: json['choices'][0]['message']['content'] as String,
    );
  }
}
