class NoInternetException implements Exception {
  String? message;

  NoInternetException([this.message]);

  @override
  String toString() {
    if (message == null) return "No Internet Connection";
    return "No Internet Connection: $message";
  }
}
