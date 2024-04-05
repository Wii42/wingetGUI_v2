class GithubLoadException implements Exception {
  Uri url;
  int statusCode;
  String? reasonPhrase;
  String? responseBody;

  GithubLoadException(
      {required this.url,
      required this.statusCode,
      this.reasonPhrase,
      this.responseBody});

  @override
  String toString() {
    return [
      'Failed to load files from Github API: $url',
      'status code: $statusCode',
      if (reasonPhrase != null) 'reason: $reasonPhrase',
      if (responseBody != null) 'response body: $responseBody'
    ].join(', ');
  }
}
