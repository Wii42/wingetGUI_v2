import 'dart:async';
import 'dart:convert';

import 'package:winget_gui/helpers/extensions/stream_modifier.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:winget_gui/winget_process/winget_process_scheduler.dart';

import '../helpers/log_stream.dart';

class WingetProcess {
  static final Logger staticLog = Logger(null, sourceType: WingetProcess);
  final String? name;
  final ProcessWrap process;
  late final Stream<List<String>> outputStream;
  final List<void Function(int)> _onDoneCallbacks = [];

  WingetProcess({
    required this.process,
    this.name,
  }) {
    outputStream = _outputStream().asBroadcastStream();
    process.exitCode.then((value) => _runOnDoneCallbacks(value));
  }

  Stream<List<String>> _outputStream() {
    Stream<String> stream = process.stdout.transform(utf8.decoder);
    return formatStream(stream);
  }

  Stream<List<String>> formatStream(Stream<String> stream) {
    return stream
        .asBroadcastStream()
        .splitStreamElementsOnNewLine()
        .removeLoadingElementsFromStream()
        .removeLeadingEmptyStringsFromStream()
        .rememberingStream();
  }

  factory WingetProcess.fromCommand(List<String> command, {String? name}) {
    ProcessWrap process = ProcessWrap.winget(command);
    printReady(process);
    return WingetProcess(process: process, name: name);
  }

  static void printReady(ProcessWrap process) {
    process.waitForReady.then((value) => staticLog.info('${process.name} ready'));
    process.exitCode.then((value) => staticLog.info('${process.name} done'));
  }

  factory WingetProcess.fromWinget(Winget winget,
      {List<String> parameters = const []}) {
    return WingetProcess.fromCommand([...winget.fullCommand, ...parameters],
        name: winget.name);
  }

  WingetProcess clone() {
    return WingetProcess.fromCommand(command, name: name);
  }

  List<String> get command => process.arguments;

  void addOnDoneCallback(void Function(int) callback) {
    _onDoneCallbacks.add(callback);
  }

  void _runOnDoneCallbacks(int exitCode) {
    for (void Function(int) callback in _onDoneCallbacks) {
      callback(exitCode);
    }
  }
}
