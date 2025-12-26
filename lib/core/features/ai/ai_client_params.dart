class AiClientParams {
  AiClientParams({required this.model, required this.apiUrl, required this.apiKey, required this.prompt});

  final String prompt;
  final String model;
  final String apiUrl;
  final String apiKey;
}
