import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:winget_gui/helpers/extensions/stream_modifier.dart';
import 'package:winget_gui/winget_commands.dart';

class WingetProcess {
  final List<String> command;
  final String? name;
  final Process process;
  late final Stream<List<String>> outputStream;

  WingetProcess({
    required this.command,
    required this.process,
    this.name,
  }) {
    outputStream = _outputStream();
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

  static Future<WingetProcess> runCommand(List<String> command,
      {String? name}) async {
    Process process = await Process.start('winget', command);
    return WingetProcess(command: command, process: process, name: name);
  }

  static Future<WingetProcess> runWinget(Winget winget) async {
    return await runCommand(winget.command, name: winget.name);
  }

  Future<WingetProcess> clone() async {
    return await runCommand(command, name: name);
  }
}
