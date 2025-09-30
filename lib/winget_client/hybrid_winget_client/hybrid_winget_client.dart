import 'package:winget_gui/package_infos/package_infos_full.dart';
import 'package:winget_gui/winget_client/cli_winget/process_scheduler_mixin.dart';
import 'package:winget_gui/winget_client/ps_client/powershell_winget_client.dart';
import 'package:winget_gui/winget_client/winget_command.dart';

import '../../l10n/generated/app_localizations.dart';
import '../cli_winget/cli_winget_client.dart';
import '../winget_client.dart';

class HybridWingetClient extends WingetClient with ProcessSchedulerMixin {
  final PowershellWingetClient psClient = PowershellWingetClient();
  final CliWingetClient cliClient;

  HybridWingetClient(AppLocalizations wingetLocale)
    : cliClient = CliWingetClient(wingetLocale);

  @override
  WingetTask<List<String>> about(CmdAbout cmd) => cliClient.about(cmd);

  @override
  WingetTask<PackageListWithHints> availablePackages(
    CmdAvailablePackages cmd,
  ) => cliClient.availablePackages(cmd);

  @override
  WingetTask<List<String>> customCommand(CmdCustom cmd) =>
      psClient.customCommand(cmd);

  @override
  WingetTask<List<String>> help(CmdHelp cmd) => psClient.help(cmd);

  @override
  WingetTask<List<String>> installPackage(CmdInstall cmd) =>
      cliClient.installPackage(cmd);

  @override
  WingetTask<PackageListWithHints> installed(CmdInstalled cmd) =>
      psClient.installed(cmd);

  @override
  WingetTask<PackageListWithHints> search(CmdSearch cmd) =>
      cliClient.search(cmd);

  @override
  WingetTask<List<String>> settings(CmdSettings cmd) => cliClient.settings(cmd);

  @override
  WingetTask<PackageInfosFull> showPackageDetails(CmdShow cmd) =>
      cliClient.showPackageDetails(cmd);

  @override
  WingetTask<List<String>> uninstallPackage(CmdUninstall cmd) =>
      cliClient.uninstallPackage(cmd);

  @override
  WingetTask<List<String>> updatePackage(CmdUpdate cmd) =>
      cliClient.updatePackage(cmd);

  @override
  WingetTask<PackageListWithHints> updates(CmdUpdates cmd) =>
      psClient.updates(cmd);
}
