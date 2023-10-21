import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:yaml/src/yaml_node.dart';

import 'info.dart';
import 'info_map_parser.dart';
import 'info_yaml_map_parser.dart';
import 'package_attribute.dart';

class InstallerInfos {
  final String Function(AppLocalizations) title;
  final Info<String>? type, sha256Hash, locale, storeProductID;
  final Info<Uri>? url;
  final Info<DateTime>? releaseDate;
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
        locale: parser.maybeDetailFromMap(PackageAttribute.installerLocale),
        storeProductID:
            parser.maybeDetailFromMap(PackageAttribute.storeProductID),
        releaseDate: parser.maybeDateTimeFromMap(PackageAttribute.releaseDate),
        otherInfos: installerDetails);
  }

  static InstallerInfos? maybeFromYamlMap({Map<dynamic, dynamic>? installerDetails}) {if (installerDetails == null || installerDetails.isEmpty) {
    return null;
  }
  InfoYamlMapParser parser = InfoYamlMapParser(map: installerDetails);return InstallerInfos(
      title: PackageAttribute.installer.title,
      type: parser.maybeDetailFromMap(PackageAttribute.installerType, key: 'InstallerType'),
      //url: parser.maybeLinkFromMap(PackageAttribute.installerURL),
      //sha256Hash: parser.maybeDetailFromMap(PackageAttribute.sha256Installer),
      //locale: parser.maybeDetailFromMap(PackageAttribute.installerLocale),
      //storeProductID:
      //parser.maybeDetailFromMap(PackageAttribute.storeProductID),
      releaseDate: parser.maybeDateTimeFromMap(PackageAttribute.releaseDate, key: 'ReleaseDate'),
      otherInfos: installerDetails.map<String, String>((key, value) => MapEntry(key.toString(), value.toString())));}
}
