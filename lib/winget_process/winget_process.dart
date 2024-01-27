import 'dart:async';
import 'dart:convert';

import 'package:winget_gui/helpers/extensions/stream_modifier.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:winget_gui/winget_process/winget_process_scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../output_handling/package_infos/package_infos_peek.dart';
import '../winget_db/winget_db.dart';

class WingetProcess {
  final String? name;
  final ProcessWrap process;
  late final Stream<List<String>> outputStream;
  final List<void Function(int)> _onDoneCallbacks = [];

  WingetProcess._({
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
    return WingetProcess._(process: process, name: name);
  }

  static void printReady(ProcessWrap process) {
    // ignore: avoid_print
    process.waitForReady.then((value) => print('${process.name} ready'));
    // ignore: avoid_print
    process.exitCode.then((value) => print('${process.name} done'));
  }

  factory WingetProcess.fromWinget(Winget winget) {
    return WingetProcess.fromCommand(winget.fullCommand, name: winget.name);
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

class UnInstallingUpdatingProcess extends WingetProcess {
  final UnInstallingUpdatingType type;
  UnInstallingUpdatingProcess._(
      {required super.process,
      super.name,
      required this.type,
      PackageInfosPeek? info,
      AppLocalizations? wingetLocale})
      : super._() {
    addOnDoneCallback(
      (exitCode) => _reloadDB(exitCode, info, wingetLocale),
    );
  }

  factory UnInstallingUpdatingProcess.create(UnInstallingUpdatingType type,
      {List<String> args = const [],
      required PackageInfosPeek? info,
      required AppLocalizations? wingetLocale}) {
    var command = [...type.winget.fullCommand, ...args];
    ProcessWrap process = ProcessWrap.winget(command);
    return UnInstallingUpdatingProcess._(
        process: process,
        name: type.winget.name,
        type: type,
        info: info,
        wingetLocale: wingetLocale);
  }

  void _reloadDB(
      int exitCode, PackageInfosPeek? info, AppLocalizations? wingetLocale) {
    print('exit code: $exitCode');
    type.reloadDB(exitCode, info, wingetLocale);
    WingetDB.instance.notifyListeners();
  }
}

enum UnInstallingUpdatingType {
  uninstall(Winget.uninstall, reloadUninstall),
  install(Winget.install, reloadInstall),
  update(Winget.upgrade, reloadUpdate);

  final Winget winget;
  final void Function(
          int exitCode, PackageInfosPeek? info, AppLocalizations? wingetLocale)
      reloadDB;
  const UnInstallingUpdatingType(this.winget, this.reloadDB);

  static void reloadUninstall(
      int exitCode, PackageInfosPeek? info, AppLocalizations? wingetLocale) {
    WingetDB wingetDB = WingetDB.instance;
    if (info != null && exitCode == 0) {
      WingetDB.instance.installed.removeInfoWhere(info.probablySamePackage);
      wingetDB.updates.removeInfoWhere(info.probablySamePackage);
    }
    if (wingetLocale != null) {
      (wingetDB.installed.reloadFuture(wingetLocale)).then(
        (_) {
          wingetDB.updates.reloadFuture(wingetLocale);
        },
      );
    }
  }

  static void reloadInstall(
      int exitCode, PackageInfosPeek? info, AppLocalizations? wingetLocale) {
    WingetDB wingetDB = WingetDB.instance;
    if (info != null && exitCode == 0) {
      wingetDB.installed.addInfo(info);
    }
    if (wingetLocale != null) wingetDB.installed.reloadFuture(wingetLocale);
  }

  static void reloadUpdate(
      int exitCode, PackageInfosPeek? info, AppLocalizations? wingetLocale) {
    WingetDB wingetDB = WingetDB.instance;
    if (info != null && exitCode == 0) {
      wingetDB.updates.removeInfoWhere(info.probablySamePackage);
    }
    if (wingetLocale != null) wingetDB.updates.reloadFuture(wingetLocale);
  }
}
