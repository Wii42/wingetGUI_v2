import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/db/package_tables.dart';
import 'package:winget_gui/l10n/generated/app_localizations.dart';

import '../winget_client/winget_client.dart';
import 'package_action_type.dart';
import 'winget_process.dart';
import 'winget_process_scheduler.dart';

class PackageActionProcess extends WingetProcess {
  final PackageActionType type;

  PackageActionProcess._({
    required super.process,
    super.name,
    required this.type,
    PackageInfosPeek? info,
    AppLocalizations? wingetLocale,
  }) {
    //addOnDoneCallback((exitCode) => _reloadDB(exitCode, info, wingetLocale));
  }

  factory PackageActionProcess(
    PackageActionType type, {
    List<String> args = const [],
    required PackageInfosPeek? info,
    required AppLocalizations? wingetLocale,
  }) {
    var command = [...type.winget.fullCommand, ...args];
    ProcessWrap process = ProcessWrap.winget(command);
    return PackageActionProcess._(
      process: process,
      name: type.winget.name,
      type: type,
      info: info,
      wingetLocale: wingetLocale,
    );
  }

  void _reloadDB(
    int exitCode,
    PackageInfosPeek? info,
      WingetClient? wingetClient,
  ) {
    if (exitCode != 0) {
      return;
    }
    type.reloadDB(exitCode, info, wingetClient);
    PackageTables.instance.notifyListeners();
  }
}
