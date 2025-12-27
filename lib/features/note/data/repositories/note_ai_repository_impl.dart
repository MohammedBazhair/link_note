import 'package:flutter/rendering.dart';

import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/features/ai/ai_client.dart';
import '../../../../core/features/ai/ai_client_params.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_ai_repository.dart';
import '../models/improved_note_model.dart';

class NoteAiRepositoryImpl implements NoteAiRepository {
  NoteAiRepositoryImpl(this._aiClient);

  final AiClient _aiClient;

  @override
  Future<AiResponseEntity> improveNoteContent(String noteContent) async {
    try {
      final params = AiClientParams(
        apiUrl: ExternalConsts.aiApiUrl,
        prompt: _buildNoteImprovementPrompt(noteContent),
      );

      final response = await _aiClient.generate(params);

      return AiResponseModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      return AiResponseEntity(text: noteContent);
    }
  }

  @override
  Future<AiResponseEntity> improveNoteTitle(Note note) async {
    try {
      final params = AiClientParams(
        apiUrl: ExternalConsts.aiApiUrl,
        prompt: _buildTitleOptimizationPrompt(note),
      );

      final response = await _aiClient.generate(params);
      
      return AiResponseModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      return AiResponseEntity(text: note.title);
    }
  }

  String _buildNoteImprovementPrompt(String note) {
    return '''
You are a professional editor.

Your task:
- Detect the language of the input text automatically.
- Rewrite the text in the SAME language as the original.
- Preserve the original meaning without adding new information.
- Correct spelling and grammar mistakes.
- Improve clarity and readability.
- Use a professional, neutral tone.

Output rules:
- Each idea or sentence must be on a separate line.
- Use correct punctuation for the detected language.
- Do NOT add explanations, titles, or extra text.
- Return ONLY the improved text.

Input text:
$note
''';
  }

  String _buildTitleOptimizationPrompt(Note note) {
    return '''
You are a professional title writer.

Your task:
- Detect the language of the note content automatically.
- Generate a concise and clear title in the SAME language.
- The title must reflect the main idea only.
- Maximum length: 6 words.
- Do NOT use punctuation marks.
- Do NOT repeat words from the previous title.

Output rules:
- Return ONLY the title.
- No explanations or extra text.

Previous title:
${note.title}

Note content:
${note.content}
''';
  }
}
