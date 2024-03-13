import 'dart:ui';

import 'package:dart_casing/dart_casing.dart';
import 'package:winget_gui/helpers/extensions/best_fitting_locale.dart';

import '../../../helpers/locale_parser.dart';
import '../../../helpers/version.dart';
import '../package_attribute.dart';
import 'full_abstract_map_parser.dart';
import 'info_json_parser.dart';

class FullJsonParser extends FullAbstractMapParser<String, dynamic> {
  Locale? locale;
  String? source;
  FullJsonParser(
      {Map<String, dynamic> details = const {}, this.locale, this.source})
      : super(details);

  @override
  Map<String, dynamic> flattenedDetailsMap() {
    Map<String, dynamic>? flattenedDetails = _getVersionMap();
    flattenedDetails?.remove(PackageAttribute.installers.apiKey);
    Map<String, dynamic> defaultLocale =
        _extractElement(flattenedDetails, 'DefaultLocale') ?? {};
    Map<String, dynamic>? selectedLocale =
        _getOptimalLocaleMap(defaultLocale, flattenedDetails);
    defaultLocale.addAll(selectedLocale ?? defaultLocale);
    flattenedDetails?.addAll(defaultLocale);
    flattenedDetails?.remove('Locales');
    List<dynamic> agreements =
        _extractElement(flattenedDetails, 'Agreements') ?? {};
    Map<String, String>? agreementMap = _extractAgreementMap(agreements);
    flattenedDetails?.addAll(agreementMap ?? {});

    flattenedDetails?[PackageAttribute.source.apiKey!] = source;
    return flattenedDetails ?? {};
  }

  dynamic _extractElement(Map<String, dynamic>? originMap, String key) {
    dynamic element = originMap?[key];
    originMap?.remove(key);
    originMap?.remove('\$type');
    return element;
  }

  Map<String, dynamic>? _getVersionMap() {
    Map<String, dynamic>? flattenedDetails = Map.from(details);
    Map<String, dynamic> data = _extractElement(flattenedDetails, 'Data');
    flattenedDetails.addAll(data);
    List<dynamic>? versions = _extractElement(flattenedDetails, 'Versions');
    Map<String, dynamic>? version = _getOptimalVersionMap(versions);
    flattenedDetails.addAll(version ?? {});
    return flattenedDetails;
  }

  Map<String, dynamic>? _getOptimalVersionMap(List<dynamic>? versions) {
    Map<String, dynamic>? version = versions?.lastOrNull;
    if (versions != null) {
      List<Version> availableVersions = versions
          .map<Version?>(
              (e) => Version.tryParse(e[PackageAttribute.version.apiKey]))
          .nonNulls
          .toList();
      Version? bestFitting = Version.primary(availableVersions);
      if (bestFitting != null) {
        version = versions.firstWhere(
            (element) =>
                Version.tryParse(element[PackageAttribute.version.apiKey]) ==
                bestFitting,
            orElse: () => version);
      }
    }
    return version;
  }

  Map<String, dynamic>? _getOptimalLocaleMap(
      Map<String, dynamic>? defaultLocale, Map<String, dynamic>? version) {
    Map<String, dynamic>? selectedLocale = defaultLocale;
    List<dynamic>? locales = version?['Locales'];
    if (locales != null && locale != null && locales.isNotEmpty) {
      List<Locale> availableLocales = locales
          .map<Locale?>((e) =>
              LocaleParser.tryParse(e[PackageAttribute.packageLocale.apiKey]))
          .nonNulls
          .toList();
      Locale? bestFitting = locale?.bestFittingLocale(availableLocales);
      if (bestFitting != null) {
        selectedLocale = locales.firstWhere(
            (element) =>
                LocaleParser.tryParse(
                    element[PackageAttribute.packageLocale.apiKey]) ==
                bestFitting,
            orElse: () => defaultLocale);
      }
    }
    return selectedLocale ?? defaultLocale;
  }

  Map<String, String>? _extractAgreementMap(List<dynamic>? agreements) {
    if (agreements == null) return null;
    Iterable<MapEntry<String?, String?>> nullableMap =
        agreements.map<MapEntry<String?, String?>>((e) {
      String? key = e['AgreementLabel'];
      if (key != null) {
        key = Casing.pascalCase(key);
      }
      String? value = e['AgreementUrl'] ?? e['Agreement'];
      return MapEntry(key, value);
    });
    Iterable<MapEntry<String, String>> nonNulls = nullableMap
        .where((element) => element.key != null && element.value != null)
        .map((e) => MapEntry(e.key!, e.value!));
    if (nonNulls.isEmpty) return null;
    return Map.fromEntries(nonNulls);
  }

  @override
  Map<String, dynamic> flattenedInstallerDetailsMap() {
    String key = PackageAttribute.installers.apiKey!;
    List<dynamic>? installers = _getVersionMap()?[key];
    return {key: installers};
  }

  @override
  InfoJsonParser getParser(Map<String, dynamic> map) {
    return InfoJsonParser(map: map);
  }
}
