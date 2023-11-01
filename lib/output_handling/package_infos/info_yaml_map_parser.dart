import 'dart:ui';

import 'package:winget_gui/output_handling/package_infos/installer_objects/computer_architecture.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/dependencies.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/install_scope.dart';
import 'package:yaml/yaml.dart';

import '../../helpers/locale_parser.dart';
import 'agreement_infos.dart';
import 'info.dart';
import 'info_with_link.dart';
import 'installer_objects/install_mode.dart';
import 'installer_objects/installer_type.dart';
import 'installer_objects/upgrade_behavior.dart';
import 'installer_objects/windows_platform.dart';
import 'package_attribute.dart';

class InfoYamlMapParser {
  Map<dynamic, dynamic> map;
  InfoYamlMapParser({required this.map});

  Info<String>? maybeStringFromMap(PackageAttribute attribute) {
    dynamic node = map[attribute.yamlKey!];
    String? detail = (node != null) ? node.toString() : null;
    map.remove(attribute.yamlKey!);
    return (detail != null)
        ? Info<String>(
            title: attribute.title, value: detail, copyable: attribute.copyable, couldBeLink: attribute.couldBeLink)
        : null;
  }

  Info<Uri>? maybeLinkFromMap(PackageAttribute infoKey) {
    Info<String>? link = maybeStringFromMap(infoKey);
    if (link == null) {
      return null;
    }
    return Info<Uri>(title: link.title, value: Uri.parse(link.value));
  }

  Info<List<InfoWithLink>>? maybeDocumentationsFromMap(
      PackageAttribute attribute) {
    YamlList? node = map[attribute.yamlKey!];
    if (node == null || node.value.isEmpty) {
      return null;
    }
    if (node.value is YamlList) {
      List<Map> entries = node.value.map<Map>((e) => e as Map).toList();
      if (entries.every((element) =>
          element.containsKey('DocumentLabel') &&
          element.containsKey('DocumentUrl'))) {
        List<InfoWithLink> linkList = entries
            .map<InfoWithLink>(
              (e) => InfoWithLink(
                  title: (_) => e['DocumentLabel'],
                  text: e['DocumentLabel'],
                  url: Uri.parse(e['DocumentUrl'])),
            )
            .toList();
        map.remove(attribute.yamlKey!);
        return Info<List<InfoWithLink>>(
            title: attribute.title, value: linkList);
      }
    }

    List<InfoWithLink> list = node
        .map((element) => InfoWithLink(title: (_) => element.toString()))
        .toList();
    map.remove(attribute.yamlKey!);
    return Info<List<InfoWithLink>>(title: attribute.title, value: list);
  }

  Info<List<T>>? maybeListFromMap<T>(PackageAttribute attribute,
      {required T Function(dynamic) parser}) {
    YamlList? node = map[attribute.yamlKey!];
    if (node == null || node.value.isEmpty) {
      return null;
    }
    map.remove(attribute.yamlKey!);
    return Info<List<T>>(
        title: attribute.title, value: node.value.map<T>(parser).toList());
  }

  Info<T>? maybeFromMap<T extends Object>(PackageAttribute attribute,
      {required T Function(dynamic) parser}) {
    Object? node = map[attribute.yamlKey!];
    if (node == null) {
      return null;
    }
    map.remove(attribute.yamlKey!);
    return Info<T>(
        title: attribute.title, value: parser(node));
  }

  Info<List<String>>? maybeStringListFromMap(PackageAttribute attribute) {
    return maybeListFromMap(attribute, parser: (e) => e.toString());
  }

  AgreementInfos? maybeAgreementFromMap() {
    return AgreementInfos.maybeFromYamlMap(
      map: map,
    );
  }

  InfoWithLink? maybeInfoWithLinkFromMap(
      {required PackageAttribute textInfo, required PackageAttribute urlInfo}) {
    return InfoWithLink.maybeFromYamlMap(
      map: map,
      textInfo: textInfo,
      urlInfo: urlInfo,
    );
  }

  Info<DateTime>? maybeDateTimeFromMap(PackageAttribute attribute) {
    Info<String>? dateInfo = maybeStringFromMap(attribute);
    if (dateInfo == null) {
      return null;
    }
    return Info<DateTime>(
        title: dateInfo.title, value: DateTime.parse(dateInfo.value));
  }

  List<String>? maybeTagsFromMap() {
    String key = PackageAttribute.tags.yamlKey!;
    YamlList? tagList = map[key] as YamlList?;
    if (tagList != null) {
      List<String> tags = tagList.map((element) => element.toString()).toList();
      map.remove(key);
      return tags;
    }
    return null;
  }

  Info<Locale>? maybeLocaleFromMap(PackageAttribute packageLocale) {
    Info<String>? localeInfo = maybeStringFromMap(packageLocale);
    if (localeInfo == null) {
      return null;
    }
    return Info<Locale>(
        title: localeInfo.title, value: LocaleParser.parse(localeInfo.value));
  }

  Info<List<WindowsPlatform>>? maybePlatformFromMap(PackageAttribute platform) {
    return maybeListFromMap(platform,
        parser: (e) => WindowsPlatform.fromYaml(e));
  }

  Info<InstallerType>? maybeInstallerTypeFromMap(
      PackageAttribute installerType) {
   return maybeValueFromMap(installerType, InstallerType.parse);
  }

  Info<ComputerArchitecture>? maybeArchitectureFromMap(
      PackageAttribute architecture) {
    return maybeValueFromMap(architecture, ComputerArchitecture.parse);
  }

  Info<InstallScope>? maybeScopeFromMap(PackageAttribute installScope) {
    return maybeValueFromMap(installScope, InstallScope.parse);
  }

  Info<List<InstallMode>>? maybeInstallModesFromMap(PackageAttribute installModes) {
    return maybeListFromMap(installModes, parser: InstallMode.fromYaml);
  }

  Info<T>? maybeValueFromMap<T extends Object>(PackageAttribute attribute, T Function(String) parser) {
    Info<String>? info = maybeStringFromMap(attribute);
    if (info == null) {
      return null;
    }
    return Info<T>(title: info.title, value: parser(info.value));
  }

  Info<InstallMode>? maybeInstallModeFromMap(PackageAttribute installMode) {
    Info<String>? modeInfo = maybeStringFromMap(installMode);
    if (modeInfo == null) {
      return null;
    }
    return Info<InstallMode>(
        title: modeInfo.title,
        value: InstallMode.maybeParse(modeInfo.value)!);
  }

  Info<UpgradeBehavior>? maybeUpgradeBehaviorFromMap(PackageAttribute upgradeBehavior) {
    return maybeValueFromMap(upgradeBehavior, UpgradeBehavior.parse);
  }

 Info<Dependencies>? maybeDependenciesFromMap(PackageAttribute dependencies) {
    return maybeFromMap<Dependencies>(dependencies, parser: (e) => Dependencies.fromYamlMap(e));
 }
}


