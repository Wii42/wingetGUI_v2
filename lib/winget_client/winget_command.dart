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

final class CmdInstall extends WingetCommand {
  const CmdInstall(
    this.id, {
    this.version,
    this.disableInteractivity = true,
    this.autoAcceptSourceAgreements = true,
    this.autoAcceptPackageAgreements = true,
  });

  final String id;
  final VersionOrString? version;
  final bool disableInteractivity;
  final bool autoAcceptSourceAgreements;
  final bool autoAcceptPackageAgreements;

  @override
  String get telemetryName => 'install';
}

final class CmdUpdate extends WingetCommand {
  const CmdUpdate(
    this.id, {
    this.disableInteractivity = true,
    this.autoAcceptSourceAgreements = true,
    this.autoAcceptPackageAgreements = true,
    this.includeUnknown = true,
  });

  final String id;
  final bool disableInteractivity;
  final bool autoAcceptSourceAgreements;
  final bool autoAcceptPackageAgreements;

  /// If true, include packages where the current version is unknown.
  final bool includeUnknown;

  @override
  String get telemetryName => 'upgrade';
}

final class CmdUninstall extends WingetCommand {
  const CmdUninstall(this.id, {this.version});

  final String id;
  final VersionOrString? version;

  @override
  String get telemetryName => 'uninstall';
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
