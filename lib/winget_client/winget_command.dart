import 'package:intl/locale.dart';
import 'package:winget_core/winget_core.dart';

import '../package_sources/package_source.dart';

sealed class WingetCommand {
  const WingetCommand();

  String get telemetryName; // für Logging/Telemetry
}

sealed class WingetPackageListCommand extends WingetCommand {
  const WingetPackageListCommand({this.filter});

  final List<PackageInfosPeek> Function(List<PackageInfosPeek>)? filter;
}

/// Command that acts on a specific package identified by [id].
/// The command changes the state of the package (like install, uninstall, update).
sealed class WingetPackageActionCommand extends WingetCommand {
  const WingetPackageActionCommand(this.id);

  final String id;

  WingetPackageActionCommand copyWithId(String id);
}

final class CmdUpdates extends WingetPackageListCommand {
  const CmdUpdates({this.includeUnknown = true, super.filter});

  /// If true, include packages where the current version is unknown.
  final bool includeUnknown;

  @override
  String get telemetryName => 'updates';
}

final class CmdInstalled extends WingetPackageListCommand {
  const CmdInstalled({super.filter});

  @override
  String get telemetryName => 'installed';
}

final class CmdAbout extends WingetCommand {
  const CmdAbout();

  @override
  String get telemetryName => 'about';
}

final class CmdHelp extends WingetCommand {
  const CmdHelp();

  @override
  String get telemetryName => 'help';
}

final class CmdSearch extends WingetPackageListCommand {
  const CmdSearch(this.query, {this.by, this.count, super.filter});

  final String query;

  /// Specifies the field to search by.
  final SearchBy? by; // null = automatic
  /// Specifies the maximum number of results to return.
  final int? count;

  @override
  String get telemetryName => 'search';
}

enum SearchBy { id, name, moniker, tag }

final class CmdAvailablePackages extends WingetPackageListCommand {
  const CmdAvailablePackages({this.count, super.filter});

  final int? count;

  @override
  String get telemetryName => 'available_packages';
}

final class CmdSettings extends WingetCommand {
  const CmdSettings();

  @override
  String get telemetryName => 'settings';
}

final class CmdInstall extends WingetPackageActionCommand {
  const CmdInstall(
    super.id, {
    this.version,
    this.disableInteractivity = true,
    this.autoAcceptSourceAgreements = true,
    this.autoAcceptPackageAgreements = true,
  });

  final VersionOrString? version;
  final bool disableInteractivity;
  final bool autoAcceptSourceAgreements;
  final bool autoAcceptPackageAgreements;

  @override
  String get telemetryName => 'install';

  @override
  CmdInstall copyWithId(String id) {
    return CmdInstall(
      id,
      version: version,
      disableInteractivity: disableInteractivity,
      autoAcceptSourceAgreements: autoAcceptSourceAgreements,
      autoAcceptPackageAgreements: autoAcceptPackageAgreements,
    );
  }
}

final class CmdUpdate extends WingetPackageActionCommand {
  const CmdUpdate(
    super.id, {
    this.disableInteractivity = true,
    this.autoAcceptSourceAgreements = true,
    this.autoAcceptPackageAgreements = true,
    this.includeUnknown = true,
  });

  final bool disableInteractivity;
  final bool autoAcceptSourceAgreements;
  final bool autoAcceptPackageAgreements;

  /// If true, include packages where the current version is unknown.
  final bool includeUnknown;

  @override
  String get telemetryName => 'upgrade';

  @override
  CmdUpdate copyWithId(String id) {
    return CmdUpdate(
      id,
      disableInteractivity: disableInteractivity,
      autoAcceptSourceAgreements: autoAcceptSourceAgreements,
      autoAcceptPackageAgreements: autoAcceptPackageAgreements,
      includeUnknown: includeUnknown,
    );
  }
}

final class CmdUninstall extends WingetPackageActionCommand {
  const CmdUninstall(super.id, {this.version});

  final VersionOrString? version;

  @override
  String get telemetryName => 'uninstall';

  @override
  CmdUninstall copyWithId(String id) {
    return CmdUninstall(id, version: version);
  }
}

final class CmdShow extends WingetCommand {
  const CmdShow(this.id, {this.source, this.userLocale});

  final PackageSource? source;
  final String id;
  final Locale? userLocale;

  @override
  String get telemetryName => 'show';
}

final class CmdCustom extends WingetCommand {
  const CmdCustom(this.arguments, {this.name = 'custom'});

  final List<String> arguments;
  final String name;

  @override
  String get telemetryName => name;
}

final class CmdRunningCommands extends WingetCommand {
  const CmdRunningCommands();

  @override
  String get telemetryName => 'running_commands';
}
