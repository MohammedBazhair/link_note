import '../../../../core/constants/internal_constants/log.dart';

class AiResponseModel {
  AiResponseModel({required this.text});

  factory AiResponseModel.empty() {
    return AiResponseModel(text: '');
  }

  factory AiResponseModel.fromJson(Map<String, dynamic> json) {
    Logger.log(message: json.toString());
    return AiResponseModel(
      text: json['choices'][0]['message']['content'] as String,
    );
  }
  final String text;
}
