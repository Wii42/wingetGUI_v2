import 'dart:ui';

import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';
import 'package:winget_gui/output_handling/package_infos/to_string_info_extensions.dart';
import 'package:winget_gui/package_sources/package_source.dart';

import '../../helpers/locale_parser.dart';
import '../../helpers/version_or_string.dart';
import 'agreement_infos.dart';
import 'info.dart';
import 'info_with_link.dart';
import 'installer_objects/installer_locale.dart';
import 'installer_objects/installer_type.dart';

abstract class InfoAbstractMapParser<A, B> {
  Map<A, B> map;
  InfoAbstractMapParser({required this.map});

  Info<String>? maybeStringFromMap(PackageAttribute attribute);

  Info<Uri>? maybeLinkFromMap(PackageAttribute infoKey) {
    Info<String>? link = maybeStringFromMap(infoKey);
    if (link == null) {
      return null;
    }
    return link.copyAs<Uri>(parser: Uri.parse);
  }

  AgreementInfos? maybeAgreementFromMap();

  InfoWithLink? maybeInfoWithLinkFromMap(
      {required PackageAttribute textInfo, required PackageAttribute urlInfo});

  Info<DateTime>? maybeDateTimeFromMap(PackageAttribute attribute) {
    return maybeValueFromMap<DateTime>(attribute, DateTime.parse);
  }

  List<String>? maybeTagsFromMap();

  Info<PackageSources> sourceFromMap(PackageAttribute packageLocale) {
    Info<String>? localeInfo = maybeStringFromMap(packageLocale);
    if (localeInfo == null) {
      return Info<PackageSources>.fromAttribute(PackageAttribute.source,
          value: PackageSources.none);
    }
    return localeInfo.copyAs<PackageSources>(parser: PackageSources.fromString);
  }

  Info<Locale>? maybeLocaleFromMap(PackageAttribute packageLocale) {
    return maybeValueFromMap<Locale>(packageLocale, LocaleParser.parse);
  }

  Info<InstallerLocale>? maybeInstallerLocaleFromMap(
      PackageAttribute packageLocale) {
    return maybeValueFromMap(packageLocale, LocaleParser.parse);
  }

  Info<T>? maybeValueFromMap<T extends Object>(
      PackageAttribute attribute, T Function(String) parser) {
    Info<String>? info = maybeStringFromMap(attribute);
    if (info == null) {
      return null;
    }
    return info.copyAs<T>(parser: parser);
  }

  Info<String>? maybeFirstLineFromInfo(Info<String>? source,
      {required PackageAttribute destination}) {
    if (source == null) {
      return null;
    }

    String firstLine = source.value.split('\n').first;
    if (firstLine.contains('. ')) {
      firstLine = '${firstLine.split('. ').first}.';
    }
    return Info<String>.fromAttribute(destination, value: firstLine);
  }

  Info<List<T>>? maybeListFromMap<T>(PackageAttribute attribute,
      {required T Function(dynamic p1) parser});

  Info<InstallerType>? maybeInstallerTypeFromMap(
      PackageAttribute installerType) {
    return maybeValueFromMap(installerType, InstallerType.parse);
  }

  Map<String, String>? getOtherInfos() {
    if (map.isEmpty) return null;
    return map.map((key, value) => MapEntry(key.toString(), value.toString()));
  }

  Info<VersionOrString>? maybeVersionOrStringFromMap(
      PackageAttribute attribute) {
    return maybeValueFromMap<VersionOrString>(attribute, VersionOrString.parse);
  }
}
