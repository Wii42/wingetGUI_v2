import 'dart:async';

import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/output_handling/output_builder.dart';
import 'package:winget_gui/output_handling/output_parser.dart';
import 'package:winget_gui/output_handling/show/package_long_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../package_infos/package_attribute.dart';
import '../package_infos/package_infos_full.dart';

const maxIdentifierLength = 100;

class ShowParser extends OutputParser {
  AppLocalizations wingetLocale;
  ShowParser(super.lines, this.wingetLocale);

  @override
  FutureOr<OutputBuilder>? parse(AppLocalizations wingetLocale) {
    return QuickOutputBuilder(
        (context) => PackageLongInfo(_extractInfos(wingetLocale)));
  }

  PackageInfosFull _extractInfos(AppLocalizations locale) {
    Map<String, String> infos = {};
    infos.addAll(_extractMainInfos());
    infos.addAll(_extractOtherInfos());

    Map<String, String>? installerDetails;
    if (infos.hasInfo(PackageAttribute.installer, locale)) {
      installerDetails = extractInstallerDetails(infos);
      infos.remove(PackageAttribute.installer.key(locale));
    }

    return PackageInfosFull.fromMap(
        details: infos, installerDetails: installerDetails, locale: locale);
  }

  Map<String, String> _extractMainInfos() {
    Map<String, String> infos = {};
    List<String> details = lines[0].trim().split(' ');

    infos[PackageAttribute.name.key(wingetLocale)] =
        details.sublist(1, details.length - 1).join(' ');
    String id = details.last.trim();
    infos[PackageAttribute.id.key(wingetLocale)] =
        id.replaceAll('[', '').replaceAll(']', '');
    return infos;
  }

  Map<String, String> _extractOtherInfos() {
    List<String> details = lines.sublist(1);
    return extractDetails(details);
  }

  Map<String, String> extractInstallerDetails(Map<String, String> infos) {
    return extractDetails(infos[PackageAttribute.installer.key(wingetLocale)]!
        .split('\n')
        .map((String line) => line.trim())
        .toList());
  }

  static Map<String, String> extractDetails(List<String> data) {
    Map<String, String> infos = {};
    String? key, value;
    for (String line in data) {
      if (!line.startsWith(' ') &&
          (line.contains(': ') || line.endsWith(':')) &&
          line.indexOf(':') <= maxIdentifierLength) {
        if (key != null && value != null) {
          infos[key] = value.replaceAll('\n\n', '\n').trim();
        }
        int splitPos = line.indexOf(':');
        key = line.substring(0, splitPos).trim();
        value = line.substring(splitPos + 1).trim();
      } else {
        value = "$value\n${line.trim()}";
      }
    }
    if (key != null) {
      infos[key] = value!.replaceAll('\n\n', '\n').trim();
    }
    return infos;
  }
}