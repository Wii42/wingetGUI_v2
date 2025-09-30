import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/package_infos/package_infos_full.dart';
import 'package:winget_gui/winget_client/winget_command.dart';

import '../output_handling/one_line_info_parser.dart';

abstract class WingetClient {
  WingetClient();

  /// Returns a stream of packages which have an update available.
  WingetTask<PackageListWithHints> updates(CmdUpdates cmd);

  /// Returns a stream of installed packages.
  WingetTask<PackageListWithHints> installed(CmdInstalled cmd);

  /// Returns infos about the underlying winget installation.
  /// Includes version and other metadata.
  WingetTask<List<String>> about(CmdAbout cmd);

  /// Returns help information for a specific command or general help
  /// if no command is specified.
  WingetTask<List<String>> help(CmdHelp cmd);

  /// Searches for packages based on the provided criteria.
  WingetTask<PackageListWithHints> search(CmdSearch cmd);

  /// Returns a stream of all available packages.
  WingetTask<PackageListWithHints> availablePackages(CmdAvailablePackages cmd);

  /// Opens the settings for the underlying winget installation.
  WingetTask<List<String>> settings(CmdSettings cmd);

  /// Installs a package based on the provided criteria.
  WingetTask<List<String>> installPackage(CmdInstall cmd);

  /// Updates a package based on the provided criteria.
  WingetTask<List<String>> updatePackage(CmdUpdate cmd);

  /// Uninstalls a package based on the provided criteria.
  WingetTask<List<String>> uninstallPackage(CmdUninstall cmd);

  /// Shows details of a specific package.
  WingetTask<PackageInfosFull> showPackageDetails(CmdShow cmd);

  /// Executes a custom winget command.
  /// Use with caution as this can run any command, when not guarded properly.
  WingetTask<List<String>> customCommand(CmdCustom cmd);

  /// Returns a stream of the number of currently running winget commands.
  Stream<int> runningCommandsLength(CmdRunningCommands cmd);

  /// Cancels a running winget command.
  Future<void> cancelTask(int taskId);

  Future<void> cancelAllTasks();
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

  WingetTask<PackageListWithHints> executePackageListCommand(
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

  WingetTask<List<String>> executePackageActionCommand(
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

class WingetTask<T extends Object> {
  /// A stream of results from the winget command.
  final Stream<T> result;
  /// The unique ID of the task.
  final int taskId;
  /// The command that was executed to create this task.
  final WingetCommand cmd;
  /// A function that can be called to retry the task.
  /// This function returns a new [WingetTask] instance.
  final WingetTask<T> Function() retry;

  /// Completes with true if the task completed successfully, false otherwise.
  final Future<bool> hasCompletedSuccessfully;

  WingetTask({
    required this.result,
    required this.taskId,
    required this.hasCompletedSuccessfully,
    required this.cmd,
    required this.retry,
  });

  Future<void> cancel(WingetClient client) async => client.cancelTask(taskId);

  /// Returns the last value emitted by the result stream as a Future.
  Future<T> resultAsFuture() => result.last;
}
