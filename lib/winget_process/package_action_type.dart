import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/db/package_tables.dart';
import 'package:winget_gui/package_actions_notifier.dart';

import '../winget_client/winget_client.dart';
import '../winget_client/winget_command.dart';

class PackageActionType {

  static void runAction(
    WingetPackageActionCommand winget,
    PackageInfos package,
    BuildContext context,
  ) {
    WingetClient client = context.read<WingetClient>();
    Stream<List<String>> commandOutputStream = client
        .executePackageActionCommand(winget);
    PackageAction action = PackageAction(
      infos: package,
      wingetCommand: winget,
      commandOutputStream: onFinished(
        commandOutputStream,
        _reloadDbOnDone(winget, package, client),
      ),
    );
    Provider.of<PackageActionsNotifier>(context, listen: false).add(action);
  }

  static void Function(bool completed) _reloadDbOnDone(
    WingetPackageActionCommand winget,
    PackageInfos package,
    WingetClient client,
  ) => (bool completed) {
    reloadDB(winget)(completed ? 0 : 1, package.toPeek(), client);
  };

  static void Function(
    int exitCode,
    PackageInfosPeek? info,
    WingetClient wingetClient,
  )
  reloadDB(WingetPackageActionCommand winget) {
    switch (winget) {
      case CmdInstall():
        return reloadInstall;
      case CmdUninstall():
        return reloadUninstall;
      case CmdUpdate():
        return reloadUpdate;
    }
  }

  static void reloadUninstall(
    int exitCode,
    PackageInfosPeek? info,
    WingetClient wingetClient,
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
    if (exitCode == 0) {
      (wingetDB.installed.reloadFuture(wingetClient)).then((_) {
        wingetDB.updates.reloadFuture(wingetClient);
      });
    }
  }

  static void reloadInstall(
    int exitCode,
    PackageInfosPeek? info,
    WingetClient wingetClient,
  ) {
    PackageTables wingetDB = PackageTables.instance;
    if (info != null && exitCode == 0) {
      wingetDB.installed.addInfo(info);
    }
    wingetDB.installed.reloadFuture(wingetClient);
  }

  static void reloadUpdate(
    int exitCode,
    PackageInfosPeek? info,
    WingetClient wingetClient,
  ) {
    PackageTables wingetDB = PackageTables.instance;
    if (info != null && exitCode == 0) {
      wingetDB.updates.removeInfoWhere(info.probablySamePackage);
    }
    wingetDB.updates.reloadFuture(wingetClient);
  }

  static Stream<T> onFinished<T>(
    Stream<T> source,
    FutureOr<void> Function(bool completed) action, {
    bool onlyOnComplete = false, // if true: don't run on cancel
  }) async* {
    var completed = false;
    try {
      await for (final e in source) {
        yield e;
      }
      completed = true; // reached natural "done"
    } finally {
      if (!onlyOnComplete || completed) {
        await action(completed);
      }
    }
  }
}
