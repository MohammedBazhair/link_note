import 'package:http/http.dart';
import 'package:link_note/core/features/network/connectivity_service.dart';
import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/features/ai/ai_client.dart';
import '../../../../core/features/ai/ai_client_params.dart';
import '../../../user/data/datasources/user_remote_data_source.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_ai_repository.dart';
import '../models/improved_note_model.dart';

class NoteAiRepositoryImpl implements NoteAiRepository {
  NoteAiRepositoryImpl(
    this._aiClient,
    this._userRemoteDataSource,
    this._connectivityService,
  );

  final AiClient _aiClient;
  final UserRemoteDataSource _userRemoteDataSource;
  final ConnectivityService _connectivityService;

  Future<int> _getCredits() async {
    final credits = await _userRemoteDataSource.readCredits();

    if (credits == 0) {
      throw const CreditsZeroException(
        'الرصيد غير كافي لاستخدام هذه الميزة يمكنك الانتظار 24 ساعة للحصول على 10 نقاط مجانا',
      );
    }

    return credits;
  }

  @override
  Future<String> improveNoteTitle(Note note) async {
    try {
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) throw const InternetException();

      if (note.ownerId == null) {
        throw const SaveNoteFirstException('احفظ الملاحظة أولا');
      }

      final credits = await _getCredits();

      final params = AiClientParams(
        apiUrl: ExternalConsts.aiApiUrl,
        prompt: _buildTitleOptimizationPrompt(note),
      );

      final response = await _aiClient.generate(params);

      final model = AiResponseModel.fromMap(response);

      if (model.error != null) throw AiServiceException(model.error!);
      await _userRemoteDataSource.updateCredits(credits - 1, note.ownerId!);
      return model.resultText ?? note.title;
    } on ClientException catch (_) {
      throw const InternetException();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> improveNoteContent(Note note) async {
    try {
      final hasConnection = await _connectivityService.hasConnection();

      if (!hasConnection) throw const InternetException();

      if (note.ownerId == null) {
        throw const SaveNoteFirstException('احفظ الملاحظة أولا');
      }

      final credits = await _getCredits();

      final params = AiClientParams(
        apiUrl: ExternalConsts.aiApiUrl,
        prompt: _buildNoteImprovementPrompt(note.content),
      );

      final response = await _aiClient.generate(params);
      final model = AiResponseModel.fromMap(response);

      if (model.error != null) throw AiServiceException(model.error!);
      await _userRemoteDataSource.updateCredits(credits - 1, note.ownerId!);
      return model.resultText??note.content;
    } on ClientException catch (_) {
      throw const InternetException();
    } catch (e) {
      rethrow;
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
