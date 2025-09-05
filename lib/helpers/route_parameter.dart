import 'package:persistent_storage_interface/interface.dart';
import 'package:winget_core/winget_core.dart';

import '../winget_client/winget_command.dart';
import 'log_stream.dart';

/// Parameters for a route.
class RouteParameter {
  /// Parameter added to the winget command.
  final WingetCommand? wingetCommand;

  /// String added to the page title.
  final String? titleAddon;

  const RouteParameter({this.wingetCommand, this.titleAddon});
}

class PackageRouteParameter extends RouteParameter {
  final PackageInfosPeek package;

  const PackageRouteParameter({
    required this.package,
    super.wingetCommand,
    super.titleAddon,
  });
}

class StringRouteParameter extends RouteParameter {
  final String string;

  const StringRouteParameter({
    required this.string,
    super.wingetCommand,
    super.titleAddon,
  });
}

class LogRouteParameter extends RouteParameter {
  /// Log message to display on the page.
  final LogMessage log;

  const LogRouteParameter({
    required this.log,
    super.wingetCommand,
    super.titleAddon,
  });
}

class SearchRouteParameter extends RouteParameter {
  final bool Function(PackageInfosPeek)? packageFilter;

  @override
  CmdSearch? get wingetCommand => super.wingetCommand as CmdSearch?;

  const SearchRouteParameter({
    this.packageFilter,
    CmdSearch? wingetCommand,
    super.titleAddon,
  }) : super(wingetCommand: wingetCommand);
}

class DBRouteParameter extends RouteParameter {
  final TableRepresentation dbTable;

  const DBRouteParameter({
    required this.dbTable,
    super.wingetCommand,
    super.titleAddon,
  });
}
