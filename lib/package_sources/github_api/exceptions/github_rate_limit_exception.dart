import 'dart:convert';

class GithubRateLimitException implements Exception {
  Uri url;
  int statusCode;
  String reasonPhrase;
  String message;
  Uri documentationUrl;
  Map<String, String> responseBodyRest;

  GithubRateLimitException({
    required this.url,
    required this.statusCode,
    required this.reasonPhrase,
    required this.message,
    required this.documentationUrl,
    this.responseBodyRest = const {},
  });

  factory GithubRateLimitException.fromJson(
      {required Uri url,
      required int statusCode,
      required String reasonPhrase,
      required String jsonBody}) {
    Map<String, dynamic> body = json.decode(jsonBody);
    String message = body['message'];
    body.remove('message');
    Uri documentationUrl = Uri.parse(body['documentation_url']);
    body.remove('documentation_url');
    return GithubRateLimitException(
      url: url,
      statusCode: statusCode,
      reasonPhrase: reasonPhrase,
      message: message,
      documentationUrl: documentationUrl,
      responseBodyRest:
          body.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  @override
  String toString() {
    return [
      'Too much requests to Github API: $url',
      'status code: $statusCode',
      'reason: $reasonPhrase',
      'message: $message',
      'documentation url: $documentationUrl',
      if (responseBodyRest.isNotEmpty) 'response body: $responseBodyRest'
    ].join(', ');
  }
}
