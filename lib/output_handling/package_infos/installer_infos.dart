import 'dart:ui';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../helpers/locale_parser.dart';
import 'info.dart';
import 'info_map_parser.dart';
import 'info_yaml_map_parser.dart';
import 'package_attribute.dart';

class InstallerInfos {
  final String Function(AppLocalizations) title;
  final Info<String>? type, sha256Hash, storeProductID;
  final Info<Uri>? url;
  final Info<DateTime>? releaseDate;
  final Info<List<Installer>>? installers;
  final Info<String>? upgradeBehavior;
  final Info<List<String>>? fileExtensions;
  final Info<Locale>? locale;
  final Info<List<WindowsPlatform>>? platform;
  final Info<String>? minimumOSVersion;
  final Info<String>? scope;
  final Info<String>? installModes;
  final Info<String>? installerSwitches;

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
        type: parser.maybeDetailFromMap(PackageAttribute.installerType),
        url: parser.maybeLinkFromMap(PackageAttribute.installerURL),
        sha256Hash: parser.maybeDetailFromMap(PackageAttribute.sha256Installer),
        locale: parser.maybeLocaleFromMap(PackageAttribute.installerLocale),
        storeProductID:
            parser.maybeDetailFromMap(PackageAttribute.storeProductID),
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
        type: parser.maybeStringFromMap(PackageAttribute.installerType,
            key: 'InstallerType'),
        locale: parser.maybeLocaleFromMap(PackageAttribute.installerLocale,
            key: 'InstallerLocale'),
        //url: parser.maybeLinkFromMap(PackageAttribute.installerURL),
        //sha256Hash: parser.maybeDetailFromMap(PackageAttribute.sha256Installer),
        releaseDate: parser.maybeDateTimeFromMap(PackageAttribute.releaseDate,
            key: 'ReleaseDate'),
        installers: parser.maybeListFromMap<Installer>(PackageAttribute.installers,
            key: 'Installers', parser: (map) {
          return Installer.fromYaml(map);
        }),
        upgradeBehavior: parser.maybeStringFromMap(PackageAttribute.upgradeBehavior,
            key: 'UpgradeBehavior'),
        fileExtensions: parser.maybeStringListFromMap(PackageAttribute.fileExtensions,
            key: 'FileExtensions'),
        platform: parser.maybePlatformFromMap(PackageAttribute.platform,
            key: 'Platform'),
        minimumOSVersion: parser.maybeStringFromMap(PackageAttribute.minimumOSVersion,
            key: 'MinimumOSVersion'),
        scope: parser.maybeStringFromMap(PackageAttribute.installScope,
            key: 'Scope'),
        installerSwitches: parser.maybeStringFromMap(PackageAttribute.installerSwitches,
            key: 'InstallerSwitches'),
        installModes: parser.maybeStringFromMap(PackageAttribute.installModes, key: 'InstallModes'),
        otherInfos: installerDetails.map<String, String>((key, value) => MapEntry(key.toString(), value.toString())));
  }
}

enum WindowsPlatform {
  universal('Windows Universal'),
  desktop('Windows Desktop'),
  ;

  final String title;
  const WindowsPlatform(this.title);

  static WindowsPlatform fromYaml(dynamic platform) {
    switch (platform) {
      case 'Windows.Universal':
        return WindowsPlatform.universal;
      case 'Windows.Desktop':
        return WindowsPlatform.desktop;
      default:
        throw ArgumentError('Unknown Windows platform: $platform');
    }
  }
}

class Installer {
  final Info<String> architecture;
  final Info<Uri> url;
  final Info<String> sha256Hash;
  final Info<Locale>? locale;
  final Info<List<WindowsPlatform>>? platform;
  final Info<String>? minimumOSVersion;
  final Info<String>? type;
  final Info<String>? scope;
  final Info<String>? signatureSha256;
  final Info<String>? elevationRequirement;
  final Info<String>? productCode;
  final Info<String>? appsAndFeaturesEntries;
  final Info<String>? switches;
  final Info<String>? modes;

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
    this.other = const {},
  });

  static Installer fromYaml(Map installerMap) {
    Map<dynamic, dynamic> map =
        installerMap.map((key, value) => MapEntry(key, value));
    InfoYamlMapParser parser = InfoYamlMapParser(map: map);
    return Installer(
      architecture: parser.maybeStringFromMap(PackageAttribute.architecture,
          key: 'Architecture')!,
      url: parser.maybeLinkFromMap(PackageAttribute.installerURL,
          key: 'InstallerUrl')!,
      sha256Hash: parser.maybeStringFromMap(PackageAttribute.sha256Installer,
          key: 'InstallerSha256')!,
      locale: parser.maybeLocaleFromMap(PackageAttribute.installerLocale,
          key: 'InstallerLocale'),
      platform: parser.maybePlatformFromMap(PackageAttribute.platform,
          key: 'Platform'),
      minimumOSVersion: parser.maybeStringFromMap(
          PackageAttribute.minimumOSVersion,
          key: 'MinimumOSVersion'),
      type: parser.maybeStringFromMap(PackageAttribute.installerType,
          key: 'InstallerType'),
      scope: parser.maybeStringFromMap(PackageAttribute.installScope,
          key: 'Scope'),
      signatureSha256: parser.maybeStringFromMap(
          PackageAttribute.signatureSha256,
          key: 'SignatureSha256'),
      elevationRequirement: parser.maybeStringFromMap(
          PackageAttribute.elevationRequirement,
          key: 'ElevationRequirement'),
      productCode: parser.maybeStringFromMap(PackageAttribute.productCode,
          key: 'ProductCode'),
      appsAndFeaturesEntries: parser.maybeStringFromMap(
          PackageAttribute.appsAndFeaturesEntries,
          key: 'AppsAndFeaturesEntries'),
      switches: parser.maybeStringFromMap(PackageAttribute.installerSwitches,
          key: 'InstallerSwitches'),
      modes: parser.maybeStringFromMap(PackageAttribute.installModes,
          key: 'InstallModes'),
      other: map.map<String, String>(
          (key, value) => MapEntry(key.toString(), value.toString())),
    );
  }

  static dynamic get(Map map, String key) {
    dynamic value = map[key];
    map.remove(key);
    return value;
  }

  static Locale? getLocale(Map map, String key) {
    String? localeString = get(map, key);
    if (localeString == null) return null;
    return LocaleParser.parse(localeString);
  }

  static String? getToString(Map map, String key) {
    dynamic value = get(map, key);
    if (value == null) return null;
    return value.toString();
  }
}
