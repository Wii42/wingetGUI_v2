import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:winget_gui/helpers/extensions/stream_modifier.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:winget_gui/winget_process/winget_process_scheduler.dart';

class WingetProcess {
  final List<String> command;
  final String? name;
  final ProcessWrap process;
  late final Stream<List<String>> outputStream;

  WingetProcess._({
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
    ProcessWrap process = ProcessWrap('winget', command);
    process.start();
    printReady(process);
    return WingetProcess._(command: command, process: process, name: name);
  }

  static void printReady(ProcessWrap process){
    process.waitForReady.then((value) => print('ready'));
  }

  static Future<WingetProcess> runWinget(Winget winget) async {
    return await runCommand(winget.fullCommand, name: winget.name);
  }

  Future<WingetProcess> clone() async {
    return await runCommand(command, name: name);
  }
}

class UnInstallingUpdatingProcess extends WingetProcess {
  final UnInstallingUpdatingType type;
  UnInstallingUpdatingProcess._(
      {required super.command,
      required super.process,
      super.name,
      required this.type})
      : super._();

  static Future<UnInstallingUpdatingProcess> run(UnInstallingUpdatingType type,
      {List<String> args = const []}) async {
    var command = [...type.winget.fullCommand, ...args];
    //Process process = await Process.start('winget', command);
    ProcessWrap process = ProcessWrap('winget', command);
    process.start();
    Future.delayed(Duration(seconds: 1), () async {
      print(process.hasStarted());
      print(await process.exitCode);
    });
    return UnInstallingUpdatingProcess._(
        command: command, process: process, name: type.winget.name, type: type);
  }
}

enum UnInstallingUpdatingType {
  uninstall(Winget.uninstall),
  install(Winget.install),
  update(Winget.upgrade);

  final Winget winget;
  const UnInstallingUpdatingType(this.winget);
}
