import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/db/package_tables.dart';
import 'package:winget_gui/package_infos/package_infos_peek.dart';

import 'package_action_type.dart';
import 'winget_process.dart';
import 'winget_process_scheduler.dart';

class PackageActionProcess extends WingetProcess {
  final PackageActionType type;

  PackageActionProcess._(
      {required super.process,
      super.name,
      required this.type,
      PackageInfosPeek? info,
      AppLocalizations? wingetLocale}) {
    addOnDoneCallback(
      (exitCode) => _reloadDB(exitCode, info, wingetLocale),
    );
  }

  factory PackageActionProcess(PackageActionType type,
      {List<String> args = const [],
      required PackageInfosPeek? info,
      required AppLocalizations? wingetLocale}) {
    var command = [...type.winget.fullCommand, ...args];
    ProcessWrap process = ProcessWrap.winget(command);
    return PackageActionProcess._(
        process: process,
        name: type.winget.name,
        type: type,
        info: info,
        wingetLocale: wingetLocale);
  }

  void _reloadDB(
      int exitCode, PackageInfosPeek? info, AppLocalizations? wingetLocale) {
    if (exitCode != 0) {
      return;
    }
    type.reloadDB(exitCode, info, wingetLocale);
    PackageTables.instance.notifyListeners();
  }
}
