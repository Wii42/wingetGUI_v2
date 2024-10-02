import 'package:winget_gui/package_infos/package_infos_peek.dart';
import 'package:winget_gui/persistent_storage/persistent_storage_interface.dart';

import 'log_stream.dart';

/// Parameters for a route.
class RouteParameter {
  /// Parameter added to the winget command.
  final List<String>? commandParameter;

  /// String added to the page title.
  final String? titleAddon;

  const RouteParameter({this.commandParameter, this.titleAddon});
}

class PackageRouteParameter extends RouteParameter {
  final PackageInfosPeek package;

  const PackageRouteParameter(
      {required this.package, super.commandParameter, super.titleAddon});
}

class StringRouteParameter extends RouteParameter {
  final String string;

  const StringRouteParameter(
      {required this.string, super.commandParameter, super.titleAddon});
}

class LogRouteParameter extends RouteParameter {
  /// Log message to display on the page.
  final LogMessage log;

  const LogRouteParameter(
      {required this.log, super.commandParameter, super.titleAddon});
}

class SearchRouteParameter extends RouteParameter {
  final bool Function(PackageInfosPeek)? packageFilter;

  const SearchRouteParameter(
      {this.packageFilter, super.commandParameter, super.titleAddon});
}

class DBRouteParameter extends RouteParameter {
  final TableRepresentation dbTable;

  const DBRouteParameter(
      {required this.dbTable, super.commandParameter, super.titleAddon});
}
