import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/output_handling/output_parser.dart';
import 'package:winget_gui/output_handling/parsed_output.dart';
import 'package:winget_gui/output_handling/show/show_builder.dart';

import '../package_infos/info.dart';
import '../package_infos/package_attribute.dart';
import '../package_infos/package_infos_full.dart';

const maxIdentifierLength = 100;

class ShowParser extends OutputParser {
  final List<String> command;
  ShowParser(super.lines, {required this.command});

  @override
  ParsedShow parse(AppLocalizations wingetLocale) {
    return ParsedShow(infos: _extractInfos(wingetLocale), command: command);
  }

  PackageInfosFull _extractInfos(AppLocalizations locale) {
    Map<String, String> infos = {};
    infos.addAll(_extractMainInfos(locale));
    infos.addAll(_extractOtherInfos());

    Map<String, String>? installerDetails;
    if (infos.hasInfo(PackageAttribute.installer, locale)) {
      installerDetails = extractInstallerDetails(infos, locale);
      infos.remove(PackageAttribute.installer.key(locale));
    }
    PackageInfosFull parsedInfos = PackageInfosFull.fromMap(
        details: infos, installerDetails: installerDetails, locale: locale);

    if(!parsedInfos.hasVersion()){
      extractVersionFromCommand(parsedInfos, '--version');
    }
    if(!parsedInfos.hasVersion()){
      extractVersionFromCommand(parsedInfos, '-v');
    }
    return parsedInfos;


  }

  void extractVersionFromCommand(PackageInfosFull parsedInfos, String keyword) {
    if(command.contains(keyword) && command.indexOf(keyword) < command.length - 1){
      parsedInfos.version = Info(title: PackageAttribute.version.title, value: command[command.indexOf(keyword) + 1]);
    }
  }

  Map<String, String> _extractMainInfos(AppLocalizations wingetLocale) {
    Map<String, String> infos = {};
    List<String> firstLine = lines[0].trim().split(' ');

    int idIndex = firstLine.indexWhere((element) =>
        element.trim().startsWith('[') && element.trim().endsWith(']'));
    if (idIndex == -1) {
      throw Exception('No id found in first line of show part: $firstLine');
    }
    int startOffset = lines[0].trim().startsWith(wingetLocale.found) ? 1 : 2;

    infos[PackageAttribute.name.key(wingetLocale)] =
        firstLine.sublist(startOffset, idIndex).join(' ');
    String id = firstLine[idIndex].trim();
    infos[PackageAttribute.id.key(wingetLocale)] =
        id.replaceAll('[', '').replaceAll(']', '');
    if (idIndex < firstLine.length - 1) {
      if (firstLine[idIndex + 1].trim() ==
          wingetLocale.infoKey(PackageAttribute.version.name)) {
        infos[PackageAttribute.version.key(wingetLocale)] =
            firstLine.sublist(idIndex + 2).join(' ');
      }
    }
    return infos;
  }

  Map<String, String> _extractOtherInfos() {
    List<String> details = lines.sublist(1);
    return extractDetails(details);
  }

  Map<String, String> extractInstallerDetails(
      Map<String, String> infos, wingetLocale) {
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

class ParsedShow extends ParsedOutput {
  final PackageInfosFull infos;
  final List<String> command;
  ParsedShow({required this.infos, required this.command});

  @override
  ShowBuilder widgetRepresentation() {
    return ShowBuilder(infos: infos, command: command);
  }

  @override
  String toString() {
    return "ParsedShow{infos: ($infos), command: $command}";
  }
}
