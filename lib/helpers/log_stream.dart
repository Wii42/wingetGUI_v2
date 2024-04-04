import 'dart:async';
import 'dart:collection';

import 'package:intl/intl.dart';
import 'package:winget_gui/helpers/extensions/stream_modifier.dart';

class LogStream {
  static final LogStream instance = LogStream._();
  final StreamController<LogMessage> _streamController =
      StreamController<LogMessage>.broadcast();
  final List<LogMessage> _messages = [];
  LogStream._() {
    addToStdOut();
  }

  Stream<LogMessage> get logStream => _streamController.stream;
  Stream<LogMessage> get errorLogsStream => _streamController.stream
      .where((element) => element.severity == LogSeverity.error);
  Stream<List<LogMessage>> get logsListStream =>
      _streamController.stream.rememberingStream();
  Stream<List<LogMessage>> get errorLogsListStream =>
      errorLogsStream.rememberingStream();

  void _log(LogMessage message) {
    _messages.add(message);
    _streamController.add(message);
  }

  void addToStdOut() {
    logStream.listen((event) {
      // ignore: avoid_print
      print(event);
    });
  }

  UnmodifiableListView<LogMessage> get messages =>
      UnmodifiableListView(_messages);
}

class LogMessage {
  final String title;
  final String? message;
  final DateTime time;
  final LogSeverity severity;
  final Type? sourceType;
  final Object? sourceObject;

  LogMessage(this.title, this.severity,
      {this.message, this.sourceType, this.sourceObject})
      : time = DateTime.now();

  @override
  String toString() {
    Type? displayType = sourceType ?? sourceObject.runtimeType;
    DateFormat formatter = DateFormat('HH:mm:ss');
    String text =
        "LogMessage: ${formatter.format(time)} $displayType: ${severity.displayName} $title";
    if (message != null) {
      text += ": ${message?.replaceAll('\n', ', ')}";
    }
    return text;
  }

  factory LogMessage.template() {
    return LogMessage('template', LogSeverity.info,
        message: 'template', sourceType: LogMessage);
  }
}

enum LogSeverity {
  info('Info'),
  warning('Warning!'),
  error('ERROR');

  final String displayName;
  const LogSeverity(this.displayName);
}

class Logger {
  final LogStream masterLogger = LogStream.instance;
  final Object? sourceObject;
  final Type? sourceType;

  Logger(this.sourceObject, {this.sourceType});

  void info(String title, {String? message}) {
    masterLogger._log(LogMessage(title, LogSeverity.info,
        message: message, sourceType: sourceType, sourceObject: sourceObject));
  }

  void error(String title, {String? message}) {
    masterLogger._log(LogMessage(title, LogSeverity.error,
        message: message, sourceType: sourceType, sourceObject: sourceObject));
  }

  void warning(String title, {String? message}) {
    masterLogger._log(LogMessage(title, LogSeverity.warning,
        message: message, sourceType: sourceType, sourceObject: sourceObject));
  }
}
