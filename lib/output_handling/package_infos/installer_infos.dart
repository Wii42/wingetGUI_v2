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

  final Map<String, String>? otherInfos;

  InstallerInfos({
    required this.title,
    this.type,
    this.url,
    this.sha256Hash,
    this.locale,
    this.storeProductID,
    this.releaseDate,
    this.otherInfos,
    this.installers,
    this.upgradeBehavior,
    this.fileExtensions,
    this.platform,
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
        type: parser.maybeDetailFromMap(PackageAttribute.installerType,
            key: 'InstallerType'),
        locale: parser.maybeLocaleFromMap(PackageAttribute.installerLocale,
            key: 'InstallerLocale'),
        //url: parser.maybeLinkFromMap(PackageAttribute.installerURL),
        //sha256Hash: parser.maybeDetailFromMap(PackageAttribute.sha256Installer),
        releaseDate: parser.maybeDateTimeFromMap(PackageAttribute.releaseDate,
            key: 'ReleaseDate'),
        installers: parser.maybeListFromMap<Installer>(
            PackageAttribute.installers,
            key: 'Installers', parser: (map) {
          return Installer.fromYaml(map);
        }),
        upgradeBehavior: parser.maybeDetailFromMap(
            PackageAttribute.upgradeBehavior,
            key: 'UpgradeBehavior'),
        fileExtensions: parser.maybeStringListFromMap(
            PackageAttribute.fileExtensions,
            key: 'FileExtensions'),
        platform: parser.maybePlatformFromMap(PackageAttribute.platform,
            key: 'Platform'),
        otherInfos: installerDetails.map<String, String>(
            (key, value) => MapEntry(key.toString(), value.toString())));
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
  final String architecture;
  final Uri url;
  final String sha256Hash;
  final Locale? locale;
  final List<WindowsPlatform>? platform;
  final String? minimumOSVersion;
  final String? type;
  final String? scope;
  final String? hashSignature;
  final String? elevationRequirement;
  final String? productCode;
  final String? appsAndFeaturesEntries;
  final String? switches;
  final String? modes;
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
    this.hashSignature,
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
    return Installer(
      architecture: get(map, 'Architecture'),
      url: Uri.parse(get(map, 'InstallerUrl')),
      sha256Hash: get(map, 'InstallerSha256'),
      locale: getLocale(map, 'InstallerLocale'),
      platform: get(map, 'Platform')
          ?.map<WindowsPlatform>((e) => WindowsPlatform.fromYaml(e))
          .toList(),
      minimumOSVersion: get(map, 'MinimumOSVersion'),
      type: get(map, 'InstallerType'),
      scope: get(map, 'Scope'),
      hashSignature: get(map, 'SignatureSha256'),
      elevationRequirement: get(map, 'ElevationRequirement'),
      productCode: get(map, 'ProductCode'),
      appsAndFeaturesEntries: getToString(map, 'AppsAndFeaturesEntries'),
      switches: getToString(map, 'InstallerSwitches'),
      modes: getToString(map, 'InstallModes'),
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
