import 'package:supabase_flutter/supabase_flutter.dart';
import 'ai_client_params.dart';

abstract class AiClient {
  Future<Map<String, dynamic>> generate(AiClientParams params);
}

class AiClientImpl implements AiClient {
  AiClientImpl(this._client);

  final FunctionsClient _client;

  @override
  Future<Map<String, dynamic>> generate(AiClientParams params) async {
    final response = await _client.invoke(
      'generate-ai',
      body: {'prompt': params.prompt},
    );

    return response.data;
  }
}
