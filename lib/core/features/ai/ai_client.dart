import 'dart:convert';

import '../network/network_clinet.dart';
import 'ai_client_params.dart';

abstract class AiClient {
  Future<Map<String, dynamic>> generate(AiClientParams params);
}

class AiClientImpl implements AiClient {
  AiClientImpl(this._client);

  final NetworkClient _client;

  @override
  Future<Map<String, dynamic>> generate(AiClientParams params) async {
    final response = await _client.post(
      params.apiUrl,
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'x-api-market-key': params.apiKey,
      },
      body: jsonEncode({
        'model': params.model,
        'messages': [
          {'role': 'user', 'content': params.prompt},
        ],
      }),
    );

    return jsonDecode(response.body);
  }
}
