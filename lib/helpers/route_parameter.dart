import '../output_handling/package_infos/package_infos_peek.dart';
import 'log_stream.dart';

class RouteParameter {
  final List<String>? commandParameter;
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

  const StringRouteParameter({required this.string, super.commandParameter, super.titleAddon});
}

class LogRouteParameter extends RouteParameter {
  final LogMessage log;

  const LogRouteParameter({required this.log, super.commandParameter, super.titleAddon});
}

class SearchRouteParameter extends RouteParameter {
  final bool Function(PackageInfosPeek)? packageFilter;

  const SearchRouteParameter({this.packageFilter, super.commandParameter, super.titleAddon});
}
