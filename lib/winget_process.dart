import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:winget_gui/helpers/extensions/stream_modifier.dart';

class WingetProcess {
  final List<String> command;
  final Process process;

  WingetProcess({required this.command, required this.process});

  Stream<List<String>> get outputStream {
    Stream<String> stream = process.stdout.transform(utf8.decoder);
    return formatStream(stream);
  }

  Stream<List<String>> formatStream(Stream<String> stream) {
    return stream
        .splitStreamElementsOnNewLine()
        .removeLoadingElementsFromStream()
        .removeLeadingEmptyStringsFromStream()
        .rememberingStream();
  }

  static Future<WingetProcess> startProcess(List<String> commands) async {
    Process process = await Process.start('winget', commands);
    return WingetProcess(command: commands, process: process);
  }
}
