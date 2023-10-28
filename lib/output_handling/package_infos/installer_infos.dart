import 'dart:ui';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/install_mode.dart';
import 'package:winget_gui/output_handling/package_infos/installer_objects/install_scope.dart';

import 'info.dart';
import 'info_map_parser.dart';
import 'info_yaml_map_parser.dart';
import 'installer_objects/installer.dart';
import 'installer_objects/installer_type.dart';
import 'installer_objects/windows_platform.dart';
import 'package_attribute.dart';

class InstallerInfos {
  final String Function(AppLocalizations) title;
  final Info<InstallerType>? type;
  final Info<String>? sha256Hash, storeProductID;
  final Info<Uri>? url;
  final Info<DateTime>? releaseDate;
  final Info<List<Installer>>? installers;
  final Info<String>? upgradeBehavior;
  final Info<List<String>>? fileExtensions;
  final Info<Locale>? locale;
  final Info<List<WindowsPlatform>>? platform;
  final Info<String>? minimumOSVersion;
  final Info<InstallScope>? scope;
  final Info<List<InstallMode>>? installModes;
  final Info<String>? installerSwitches;
  final Info<String>? elevationRequirement;
  final Info<String>? productCode;
  final Info<String>? appsAndFeaturesEntries;

  final Map<String, String>? otherInfos;

  InstallerInfos({
    required this.title,
    this.type,
    this.url,
    this.sha256Hash,
    this.locale,
    this.storeProductID,
    this.releaseDate,
    this.installers,
    this.upgradeBehavior,
    this.fileExtensions,
    this.platform,
    this.minimumOSVersion,
    this.scope,
    this.installModes,
    this.installerSwitches,
    this.elevationRequirement,
    this.productCode,
    this.appsAndFeaturesEntries,
    this.otherInfos,
  });

  static maybeFromMap(
      {required Map<String, String>? installerDetails,
      required AppLocalizations locale}) {
    if (installerDetails == null || installerDetails.isEmpty) {
      return null;
    }
    InfoMapParser parser = InfoMapParser(map: installerDetails, locale: locale);
    return InstallerInfos(
        title: PackageAttribute.installer.title,
        type: parser.maybeInstallerTypeFromMap(PackageAttribute.installerType),
        url: parser.maybeLinkFromMap(PackageAttribute.installerURL),
        sha256Hash: parser.maybeStringFromMap(PackageAttribute.sha256Installer),
        locale: parser.maybeLocaleFromMap(PackageAttribute.installerLocale),
        storeProductID:
            parser.maybeStringFromMap(PackageAttribute.storeProductID),
        releaseDate: parser.maybeDateTimeFromMap(PackageAttribute.releaseDate),
        otherInfos: installerDetails);
  }

  static InstallerInfos? maybeFromYamlMap(
      {Map<dynamic, dynamic>? installerDetails}) {
    if (installerDetails == null || installerDetails.isEmpty) {
      return null;
    }
    InfoYamlMapParser parser = InfoYamlMapParser(map: installerDetails);
    return InstallerInfos(
        title: PackageAttribute.installer.title,
        type: parser.maybeInstallerTypeFromMap(PackageAttribute.installerType),
        locale: parser.maybeLocaleFromMap(PackageAttribute.installerLocale),
        releaseDate: parser.maybeDateTimeFromMap(PackageAttribute.releaseDate),
        installers: parser.maybeListFromMap<Installer>(
            PackageAttribute.installers, parser: (map) {
          return Installer.fromYaml(map);
        }),
        upgradeBehavior:
            parser.maybeStringFromMap(PackageAttribute.upgradeBehavior),
        fileExtensions:
            parser.maybeStringListFromMap(PackageAttribute.fileExtensions),
        platform: parser.maybePlatformFromMap(PackageAttribute.platform),
        minimumOSVersion:
            parser.maybeStringFromMap(PackageAttribute.minimumOSVersion),
        scope: parser.maybeScopeFromMap(PackageAttribute.installScope),
        installerSwitches:
            parser.maybeStringFromMap(PackageAttribute.installerSwitches),
        installModes: parser.maybeInstallModesFromMap(PackageAttribute.installModes),
        elevationRequirement:
            parser.maybeStringFromMap(PackageAttribute.elevationRequirement),
        productCode: parser.maybeStringFromMap(PackageAttribute.productCode),
        appsAndFeaturesEntries: parser.maybeStringFromMap(
            PackageAttribute.appsAndFeaturesEntries),
        otherInfos: installerDetails.map<String, String>(
            (key, value) => MapEntry(key.toString(), value.toString())));
  }
}
