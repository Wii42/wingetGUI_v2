import '../output_handling/package_infos/package_infos_peek.dart';

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
