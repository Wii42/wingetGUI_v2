import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:winget_gui/winget_process/package_action_process.dart';

import '../output_handling/output_handler.dart';
import '../output_handling/package_infos/package_infos.dart';
import '../output_handling/package_infos/package_infos_peek.dart';
import '../package_actions_notifier.dart';
import '../winget_commands.dart';
import '../winget_db/winget_db.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum PackageActionType {
  uninstall(Winget.uninstall, reloadUninstall),
  install(Winget.install, reloadInstall),
  update(Winget.upgrade, reloadUpdate);

  final Winget winget;
  final void Function(
          int exitCode, PackageInfosPeek? info, AppLocalizations? wingetLocale)
      reloadDB;
  const PackageActionType(this.winget, this.reloadDB);

  List<String> createCommand(PackageInfos package) {
    return [...winget.fullCommand, ...commandArgs(package)];
  }

  List<String> commandArgs(PackageInfos package) {
    return [
      '--id',
      package.id!.value,
      if (winget != Winget.upgrade && package.hasVersion()) ...[
        '-v',
        package.version!.value.stringValue
      ],
    ];
  }

  void runAction(PackageInfos package, BuildContext context) {
    PackageActionProcess process = PackageActionProcess(
      this,
      args: commandArgs(package),
      info: package.toPeek(),
      wingetLocale: OutputHandler.getWingetLocale(context),
    );
    PackageAction action =
        PackageAction(process: process, infos: package, type: this);
    Provider.of<PackageActionsNotifier>(context, listen: false).add(action);
  }

  static void reloadUninstall(
      int exitCode, PackageInfosPeek? info, AppLocalizations? wingetLocale) {
    WingetDB wingetDB = WingetDB.instance;
    if (exitCode != 0) {
      return;
    }
    if (info != null && exitCode == 0) {
      WingetDB.instance.installed.removeInfoWhere(info.probablySamePackage);
      wingetDB.updates.removeInfoWhere(info.probablySamePackage);
    }
    if (wingetLocale != null && exitCode == 0) {
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
