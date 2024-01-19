class DBMessage {
  final DBStatus status;
  final String? message;

  DBMessage(this.status, {this.message});
}

enum DBStatus { loading, ready, error }
