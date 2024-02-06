import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:winget_gui/helpers/extensions/stream_modifier.dart';

class LogStream {
  static final LogStream instance = LogStream._();
  final StreamController<LogMessage> _streamController =
      StreamController<LogMessage>.broadcast();

  LogStream._(){addToStdOut();}

  Stream<LogMessage> get logStream => _streamController.stream;
  Stream<LogMessage> get errorLogsStream => _streamController.stream
      .where((element) => element.severity == LogSeverity.error);
  Stream<List<LogMessage>> get logsListStream =>
      _streamController.stream.rememberingStream();
  Stream<List<LogMessage>> get errorLogsListStream =>
      errorLogsStream.rememberingStream();

  void _log(LogMessage message) {
    _streamController.add(message);
  }

  void addToStdOut() {
    logStream.listen((event) {
      if (kDebugMode) {
        print(event);
      }
    });
  }
}

class LogMessage {
  final String message;
  final DateTime time;
  final LogSeverity severity;
  final Type? sourceType;
  final Object? sourceObject;

  LogMessage(this.message, this.severity, {this.sourceType, this.sourceObject})
      : time = DateTime.now();

  @override
  String toString() {
    Type? displayType = sourceType ?? sourceObject.runtimeType;
    return "LogMessage: $time $displayType: $severity $message";
  }
}

enum LogSeverity {
  info,
  warning,
  error,
}

class Logger {
  final LogStream masterLogger = LogStream.instance;
  final Object? sourceObject;
  final Type? sourceType;

  Logger(this.sourceObject, {this.sourceType});

  void info(String message) {
    masterLogger._log(LogMessage(message, LogSeverity.info));
  }

  void error(String message) {
    masterLogger._log(LogMessage(message, LogSeverity.error));
  }

  void warning(String message) {
    masterLogger._log(LogMessage(message, LogSeverity.warning));
  }
}
