import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:winget_gui/output_handling/package_infos/info_json_parser.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/identifying_property.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/install_mode.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/install_scope.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/installer_list_extension.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/upgrade_behavior.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../info.dart';
import '../info_yaml_parser.dart';
import '../package_attribute.dart';
import 'computer_architecture.dart';
import 'expected_return_code.dart';
import 'installer_locale.dart';
import 'installer_type.dart';
import 'windows_platform.dart';

typedef Property = Info<IdentifyingProperty>? Function(Installer);

class Installer {
  static final Info<ComputerArchitecture> fallbackArchitecture =
      Info<ComputerArchitecture>.fromAttribute(PackageAttribute.architecture,
          value: ComputerArchitecture.matchAll);

  final Info<ComputerArchitecture> architecture;
  final Info<Uri>? url;
  final Info<String>? sha256Hash;
  final Info<InstallerLocale>? locale;
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
  final Info<List<ExpectedReturnCode>>? expectedReturnCodes;
  final Info<List<int>>? successCodes;

  final Map<String, String> other;

  Installer({
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
    this.expectedReturnCodes,
    this.successCodes,
    this.other = const {},
  });

  static final Map<PackageAttribute, Property> identifyingProperties = {
    PackageAttribute.architecture: (e) => e.architecture,
    PackageAttribute.installerType: (e) => e.type,
    PackageAttribute.installerLocale: (e) => e.locale,
    PackageAttribute.installScope: (e) => e.scope,
    PackageAttribute.nestedInstallerType: (e) => e.nestedInstallerType,
  };

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
      locale:
          parser.maybeInstallerLocaleFromMap(PackageAttribute.installerLocale),
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
      expectedReturnCodes: parser.maybeExpectedReturnCodesFromMap(
          PackageAttribute.expectedReturnCodes),
      successCodes: parser.maybeListFromMap(
          PackageAttribute.installerSuccessCodes,
          parser: (e) => int.parse(e.toString())),
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
      locale:
          parser.maybeInstallerLocaleFromMap(PackageAttribute.installerLocale),
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
      storeProductID:
          parser.maybeStringFromMap(PackageAttribute.storeProductID),
      markets: parser.maybeStringFromMap(PackageAttribute.markets),
      packageFamilyName:
          parser.maybeStringFromMap(PackageAttribute.packageFamilyName),
      expectedReturnCodes: parser.maybeExpectedReturnCodesFromMap(
          PackageAttribute.expectedReturnCodes),
      successCodes: parser.maybeListFromMap(
          PackageAttribute.installerSuccessCodes,
          parser: (e) => int.parse(e.toString())),
      other: parser.getOtherInfos() ?? {},
    );
  }

  String uniqueProperties(List<Installer> installerList, BuildContext context,
      {bool longNames = false}) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    List<String> preview = [];
    if (installerList.length >= 2) {
      Map<PackageAttribute, bool> isUnique =
          installerList.areIdentifyingPropertiesUnique();
      if (isUnique[PackageAttribute.architecture]!) {
        preview.add(architecture.value.title());
      }
      if (isUnique[PackageAttribute.installerType]!) {
        if (type != null) {
          InstallerType value = type!.value;
          preview.add(value.shortTitle());
        }
      }
      if (isUnique[PackageAttribute.installerLocale]!) {
        if (locale != null) {
          Locale value = locale!.value;
          preview.add(longNames
              ? LocaleNames.of(context)!.nameOf(value.toLanguageTag()) ??
                  value.toLanguageTag()
              : value.toLanguageTag());
        }
      }
      if (isUnique[PackageAttribute.installScope]!) {
        if (scope != null) {
          preview.add(scope!.value.title(localizations));
        }
      }
    }
    return preview.join(' ');
  }
}
