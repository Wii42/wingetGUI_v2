import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/db/package_tables.dart';
import 'package:winget_gui/output_handling/output_handler.dart';
import 'package:winget_gui/package_actions_notifier.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:winget_gui/winget_process/package_action_process.dart';

import '../winget_client/winget_client.dart';

enum PackageActionType {
  uninstall(Winget.uninstall, reloadUninstall),
  install(Winget.install, reloadInstall),
  update(Winget.upgrade, reloadUpdate);

  final Winget winget;
  final void Function(
    int exitCode,
    PackageInfosPeek? info,
    WingetClient? wingetClient,
  )
  reloadDB;

  const PackageActionType(this.winget, this.reloadDB);

  List<String> createCommand(PackageInfos package) {
    return [...winget.fullCommand, ...commandArgs(package)];
  }

  List<String> commandArgs(PackageInfos package) {
    return [
      '--id',
      package.id!.value.string,
      if (winget != Winget.upgrade && package.hasVersion()) ...[
        '-v',
        package.version!.value.stringValue,
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
    PackageAction action = PackageAction(
      process: process,
      infos: package,
      type: this,
    );
    Provider.of<PackageActionsNotifier>(context, listen: false).add(action);
  }

  static void reloadUninstall(
    int exitCode,
    PackageInfosPeek? info,
    WingetClient? wingetClient,
  ) {
    PackageTables wingetDB = PackageTables.instance;
    if (exitCode != 0) {
      return;
    }
    if (info != null && exitCode == 0) {
      PackageTables.instance.installed.removeInfoWhere(
        info.probablySamePackage,
      );
      wingetDB.updates.removeInfoWhere(info.probablySamePackage);
    }
    if (wingetClient != null && exitCode == 0) {
      (wingetDB.installed.reloadFuture(wingetClient)).then((_) {
        wingetDB.updates.reloadFuture(wingetClient);
      });
    }
  }

  static void reloadInstall(
    int exitCode,
    PackageInfosPeek? info,
    WingetClient? wingetClient,
  ) {
    PackageTables wingetDB = PackageTables.instance;
    if (info != null && exitCode == 0) {
      wingetDB.installed.addInfo(info);
    }
    if (wingetClient != null) wingetDB.installed.reloadFuture(wingetClient);
  }

  static void reloadUpdate(
    int exitCode,
    PackageInfosPeek? info,
    WingetClient? wingetClient,
  ) {
    PackageTables wingetDB = PackageTables.instance;
    if (info != null && exitCode == 0) {
      wingetDB.updates.removeInfoWhere(info.probablySamePackage);
    }
    if (wingetClient != null) wingetDB.updates.reloadFuture(wingetClient);
  }
}
