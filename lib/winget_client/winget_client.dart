import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/package_infos/package_infos_full.dart';
import 'package:winget_gui/winget_client/winget_command.dart';

import '../output_handling/one_line_info_parser.dart';

abstract class WingetClient {
  WingetClient();

  /// Returns a stream of packages which have an update available.
  Stream<PackageListWithHints> updates(CmdUpdates cmd);

  /// Returns a stream of installed packages.
  Stream<PackageListWithHints> installed(CmdInstalled cmd);

  /// Returns infos about the underlying winget installation.
  /// Includes version and other metadata.
  Future<List<String>> about(CmdAbout cmd);

  /// Returns help information for a specific command or general help
  /// if no command is specified.
  Future<List<String>> help(CmdHelp cmd);

  /// Searches for packages based on the provided criteria.
  Stream<PackageListWithHints> search(CmdSearch cmd);

  /// Returns a stream of all available packages.
  Stream<PackageListWithHints> availablePackages(CmdAvailablePackages cmd);

  /// Opens the settings for the underlying winget installation.
  Future<List<String>> settings(CmdSettings cmd);

  /// Installs a package based on the provided criteria.
  Stream<List<String>> installPackage(CmdInstall cmd);

  /// Updates a package based on the provided criteria.
  Stream<List<String>> updatePackage(CmdUpdate cmd);

  /// Uninstalls a package based on the provided criteria.
  Stream<List<String>> uninstallPackage(CmdUninstall cmd);

  /// Shows details of a specific package.
  Future<PackageInfosFull> showPackageDetails(CmdShow cmd);

  /// Executes a custom winget command.
  /// Use with caution as this can run any command, when not guarded properly.
  Stream<List<String>> customCommand(CmdCustom cmd);

  /// Returns a stream of the number of currently running winget commands.
  Stream<int> runningCommandsLength(CmdRunningCommands cmd);

  /// Cancels a running winget command.
  void cancelCommand(WingetCommand cmd);
}



final class PackageListWithHints {
  final List<PackageInfosPeek> packages;
  final List<OneLineInfo> hints;

  PackageListWithHints(this.packages, this.hints);
}

extension ExecuteCommand on WingetClient {
  /// Executes a [WingetCommand] and returns the appropriate result.
  /// The result type depends on the specific command executed.
  dynamic executeCommand(WingetCommand command) {
    switch (command) {
      case CmdUpdates():
        return updates(command);
      case CmdInstalled():
        return installed(command);
      case CmdAbout():
        return about(command);
      case CmdHelp():
        return help(command);
      case CmdSearch():
        return search(command);
      case CmdAvailablePackages():
        return availablePackages(command);
      case CmdSettings():
        return settings(command);
      case CmdInstall():
        return installPackage(command);
      case CmdUpdate():
        return updatePackage(command);
      case CmdUninstall():
        return uninstallPackage(command);
      case CmdShow():
        return showPackageDetails(command);
      case CmdCustom():
        return customCommand(command);
      case CmdRunningCommands():
        return runningCommandsLength(command);
    }
  }

  Stream<PackageListWithHints> executePackageListCommand(
      WingetPackageListCommand command,
  ) {
    switch (command) {
      case CmdUpdates():
        return updates(command);
      case CmdInstalled():
        return installed(command);
      case CmdSearch():
        return search(command);
      case CmdAvailablePackages():
        return availablePackages(command);
      }
  }

  Stream<List<String>> executePackageActionCommand(
      WingetPackageActionCommand command,
  ) {
    switch (command) {
      case CmdInstall():
        return installPackage(command);
      case CmdUpdate():
        return updatePackage(command);
      case CmdUninstall():
        return uninstallPackage(command);
      }
  }
}
