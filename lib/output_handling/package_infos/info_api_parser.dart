import 'package:winget_gui/output_handling/package_infos/info_abstract_map_parser.dart';
import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';

import 'info.dart';
import 'info_with_link.dart';
import 'installer_objects/computer_architecture.dart';
import 'installer_objects/install_mode.dart';
import 'installer_objects/install_scope.dart';
import 'installer_objects/upgrade_behavior.dart';
import 'installer_objects/windows_platform.dart';

abstract class InfoApiParser<A> extends InfoAbstractMapParser<A, dynamic> {
  InfoApiParser({required super.map});

  @override
  Info<String>? maybeStringFromMap(PackageAttribute attribute) {
    dynamic node = map[attribute.apiKey!];
    String? detail = (node != null) ? node.toString() : null;
    map.remove(attribute.apiKey!);
    return (detail != null)
        ? Info<String>.fromAttribute(attribute, value: detail)
        : null;
  }

  Info<T>? maybeFromMap<T extends Object>(PackageAttribute attribute,
      {required T Function(dynamic) parser}) {
    Object? node = map[attribute.apiKey!];
    if (node == null) {
      return null;
    }
    map.remove(attribute.apiKey!);
    return Info<T>.fromAttribute(attribute, value: parser(node));
  }

  Info<List<String>>? maybeStringListFromMap(PackageAttribute attribute) {
    return maybeListFromMap(attribute, parser: (e) => e.toString());
  }

  Info<List<WindowsPlatform>>? maybePlatformFromMap(PackageAttribute platform) {
    return maybeListFromMap(platform,
        parser: (e) => WindowsPlatform.fromYaml(e));
  }

  Info<ComputerArchitecture>? maybeArchitectureFromMap(
      PackageAttribute architecture) {
    return maybeValueFromMap(architecture, ComputerArchitecture.parse);
  }

  Info<InstallScope>? maybeScopeFromMap(PackageAttribute installScope) {
    return maybeValueFromMap(installScope, InstallScope.parse);
  }

  Info<List<InstallMode>>? maybeInstallModesFromMap(
      PackageAttribute installModes) {
    return maybeListFromMap(installModes, parser: InstallMode.fromYaml);
  }

  Info<InstallMode>? maybeInstallModeFromMap(PackageAttribute installMode) {
    return maybeValueFromMap(installMode, InstallMode.parse);
  }

  Info<UpgradeBehavior>? maybeUpgradeBehaviorFromMap(
      PackageAttribute upgradeBehavior) {
    return maybeValueFromMap(upgradeBehavior, UpgradeBehavior.parse);
  }

  @override
  InfoWithLink? maybeInfoWithLinkFromMap(
      {required PackageAttribute textInfo, required PackageAttribute urlInfo}) {
    return InfoWithLink.maybeFromApiMap(
      map: map,
      textInfo: textInfo,
      urlInfo: urlInfo,
    );
  }
}
