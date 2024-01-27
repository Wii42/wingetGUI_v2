import '../output_handling/package_infos/package_infos_peek.dart';
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