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
}

final class PackageListWithHints{
  final List<PackageInfosPeek> packages;
  final List<OneLineInfo> hints;

  PackageListWithHints(this.packages, this.hints);
}
