import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/package_infos/info_json_parser.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/install_mode.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/install_scope.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/installer_list_extension.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/upgrade_behavior.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../info.dart';
import '../info_yaml_parser.dart';
import '../package_attribute.dart';
import 'computer_architecture.dart';
import 'installer_type.dart';
import 'windows_platform.dart';

class Installer {
  static final Info<ComputerArchitecture> fallbackArchitecture =
      Info<ComputerArchitecture>.fromAttribute(PackageAttribute.architecture,
          value: ComputerArchitecture.matchAll);

  final Info<ComputerArchitecture> architecture;
  final Info<Uri>? url;
  final Info<String>? sha256Hash;
  final Info<Locale>? locale;
  final Info<List<WindowsPlatform>>? platform;
  final Info<String>? minimumOSVersion;
  final Info<InstallerType>? type;
  final Info<InstallScope>? scope;
  final Info<String>? signatureSha256;
  final Info<String>? elevationRequirement;
  final Info<String>? productCode;
  final Info<String>? appsAndFeaturesEntries;
  final Info<String>? switches;
  final Info<List<InstallMode>>? modes;
  final Info<UpgradeBehavior>? upgradeBehavior;
  final Info<InstallerType>? nestedInstallerType;
  final Info<List<String>>? availableCommands;
  final Info<String>? storeProductID;
  final Info<String>? markets;
  final Info<String>? packageFamilyName;

  final Map<String, String> other;

  const Installer({
    required this.architecture,
    required this.url,
    required this.sha256Hash,
    this.locale,
    this.platform,
    this.minimumOSVersion,
    this.type,
    this.scope,
    this.signatureSha256,
    this.elevationRequirement,
    this.productCode,
    this.appsAndFeaturesEntries,
    this.switches,
    this.modes,
    this.nestedInstallerType,
    this.upgradeBehavior,
    this.availableCommands,
    this.storeProductID,
    this.markets,
    this.packageFamilyName,
    this.other = const {},
  });

  static Installer fromYaml(Map installerMap) {
    Map<dynamic, dynamic> map =
        installerMap.map((key, value) => MapEntry(key, value));
    InfoYamlParser parser = InfoYamlParser(map: map);
    return Installer(
      architecture:
          parser.maybeArchitectureFromMap(PackageAttribute.architecture) ??
              fallbackArchitecture,
      url: parser.maybeLinkFromMap(PackageAttribute.installerURL),
      sha256Hash: parser.maybeStringFromMap(PackageAttribute.sha256Installer),
      locale: parser.maybeLocaleFromMap(PackageAttribute.installerLocale),
      platform: parser.maybePlatformFromMap(PackageAttribute.platform),
      minimumOSVersion:
          parser.maybeStringFromMap(PackageAttribute.minimumOSVersion),
      type: parser.maybeInstallerTypeFromMap(PackageAttribute.installerType),
      scope: parser.maybeScopeFromMap(PackageAttribute.installScope),
      signatureSha256:
          parser.maybeStringFromMap(PackageAttribute.signatureSha256),
      elevationRequirement:
          parser.maybeStringFromMap(PackageAttribute.elevationRequirement),
      productCode: parser.maybeStringFromMap(PackageAttribute.productCode),
      appsAndFeaturesEntries:
          parser.maybeStringFromMap(PackageAttribute.appsAndFeaturesEntries),
      switches: parser.maybeStringFromMap(PackageAttribute.installerSwitches),
      modes: parser.maybeInstallModesFromMap(PackageAttribute.installModes),
      nestedInstallerType: parser
          .maybeInstallerTypeFromMap(PackageAttribute.nestedInstallerType),
      upgradeBehavior:
          parser.maybeUpgradeBehaviorFromMap(PackageAttribute.upgradeBehavior),
      availableCommands:
          parser.maybeStringListFromMap(PackageAttribute.availableCommands),
      other: map.map<String, String>(
          (key, value) => MapEntry(key.toString(), value.toString())),
    );
  }

  static Installer fromJson(Map<String, dynamic> installerMap) {
    InfoJsonParser parser = InfoJsonParser(map: installerMap);
    return Installer(
      architecture:
          parser.maybeArchitectureFromMap(PackageAttribute.architecture) ??
              fallbackArchitecture,
      url: parser.maybeLinkFromMap(PackageAttribute.installerURL),
      sha256Hash: parser.maybeStringFromMap(PackageAttribute.sha256Installer),
      locale: parser.maybeLocaleFromMap(PackageAttribute.installerLocale),
      platform: parser.maybePlatformFromMap(PackageAttribute.platform),
      minimumOSVersion:
          parser.maybeStringFromMap(PackageAttribute.minimumOSVersion),
      type: parser.maybeInstallerTypeFromMap(PackageAttribute.installerType),
      scope: parser.maybeScopeFromMap(PackageAttribute.installScope),
      signatureSha256:
          parser.maybeStringFromMap(PackageAttribute.signatureSha256),
      elevationRequirement:
          parser.maybeStringFromMap(PackageAttribute.elevationRequirement),
      productCode: parser.maybeStringFromMap(PackageAttribute.productCode),
      appsAndFeaturesEntries:
          parser.maybeStringFromMap(PackageAttribute.appsAndFeaturesEntries),
      switches: parser.maybeStringFromMap(PackageAttribute.installerSwitches),
      modes: parser.maybeInstallModesFromMap(PackageAttribute.installModes),
      nestedInstallerType: parser
          .maybeInstallerTypeFromMap(PackageAttribute.nestedInstallerType),
      upgradeBehavior:
          parser.maybeUpgradeBehaviorFromMap(PackageAttribute.upgradeBehavior),
      availableCommands:
          parser.maybeStringListFromMap(PackageAttribute.availableCommands),
      storeProductID: parser.maybeStringFromMap(PackageAttribute.storeProductID),
      markets: parser.maybeStringFromMap(PackageAttribute.markets),
      packageFamilyName:
          parser.maybeStringFromMap(PackageAttribute.packageFamilyName),
      other: parser.getOtherInfos() ?? {},
    );
  }

  String uniqueProperties(List<Installer> installerList, BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    List<String> preview = [];
    if (installerList.length >= 2) {
      if (!installerList.isFeatureEverywhereTheSame((e) => e.architecture)) {
        preview.add(architecture.value.title);
      }
      if (!installerList.isFeatureEverywhereTheSame((e) => e.type)) {
        if (type != null) {
          preview.add(type!.value.shortTitle);
        }
      }
      if (!installerList.isFeatureEverywhereTheSame((e) => e.locale)) {
        if (locale != null) {
          preview.add(locale!.value.toLanguageTag());
        }
      }
      if (!installerList.isFeatureEverywhereTheSame((e) => e.scope)) {
        if (scope != null) {
          preview.add(scope!.value.title(localizations));
        }
      }
    }
    return preview.join(' ');
  }
}
