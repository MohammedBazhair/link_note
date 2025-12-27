import 'dart:convert';

import '../../constants/external_constants/external_constants.dart';
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
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ExternalConsts.supabaseAnonKey}',
      },
      body: jsonEncode({'prompt': params.prompt}),
    );

    return jsonDecode(response.body);
  }
}
