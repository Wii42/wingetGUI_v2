class NoInternetException implements Exception {
  String? message;

  NoInternetException([message]);

  @override
  String toString() {
    if (message == null) return "No Internet Connection";
    return "No Internet Connection: $message";
  }
}
