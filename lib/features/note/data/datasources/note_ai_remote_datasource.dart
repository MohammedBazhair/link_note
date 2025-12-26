import 'package:flutter/rendering.dart';
import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/features/ai/ai_client.dart';
import '../../../../core/features/ai/ai_client_params.dart';
import '../models/improved_note_model.dart';

abstract class NoteAiRemoteDataSource {
  Future<AiResponseModel> improveNote(String note);
}

class NoteAiRemoteDataSourceImpl implements NoteAiRemoteDataSource {
  NoteAiRemoteDataSourceImpl(this._aiClient);
  final AiClient _aiClient;

  @override
  Future<AiResponseModel> improveNote(String note) async {
    try {
      final prompt = _buildPrompt(note);

      final params = AiClientParams(
        model: 'gpt-4.1-nano',
        apiUrl: ExternalConsts.aiApiUrl,
        apiKey: ExternalConsts.apiMarketKey,
        prompt: prompt,
      );

      final response = await _aiClient.generate(params);


      return AiResponseModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      return AiResponseModel.empty();
    }
  }

  String _buildPrompt(String note) {
    return '''
صياغة النص التالي باللغة العربية بأسلوب واضح وسلس
واجعل كل معلومة وجملة في سطر جديد
واستعمل العلامات الإملائية وعلامات الترقيم
وصحح الأخطاء النحوية
وابدأ كل جملة جديدة بعلامة (•):

$note
''';
  }
}
