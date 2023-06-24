import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/output_handling/output_part.dart';
import 'package:winget_gui/output_handling/show/package_long_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../info_enum.dart';
import '../infos.dart';

const maxIdentifierLength = 100;

class ShowPart extends OutputPart {
  ShowPart(super.lines);

  @override
  Future<Widget?> representation(BuildContext context) async {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return PackageLongInfo(_extractInfos(locale));
  }

  Infos _extractInfos(AppLocalizations locale) {
    Map<String, String> infos = {};
    infos.addAll(_extractMainInfos(locale));
    infos.addAll(_extractOtherInfos());

    Map<String, String>? installerDetails;
    if (infos.hasInfo(Info.installer, locale)) {
      installerDetails = extractInstallerDetails(infos, locale);
      infos.remove(Info.installer.key(locale));
    }

    List<String>? tags;
    if (infos.hasInfo(Info.tags, locale)) {
      tags = extractTags(infos, locale);
      infos.remove(Info.tags.key(locale));
    }

    return Infos(
        details: infos, installerDetails: installerDetails, tags: tags);
  }

  Map<String, String> _extractMainInfos(AppLocalizations locale) {
    Map<String, String> infos = {};
    List<String> details = lines[0].trim().split(' ');

    infos[Info.name.key(locale)] = details.sublist(1, details.length - 1).join(' ');
    String id = details.last.trim();
    infos[Info.id.key(locale)] = id.replaceAll('[', '').replaceAll(']', '');
    return infos;
  }

  Map<String, String> _extractOtherInfos() {
    List<String> details = lines.sublist(1);
    return extractDetails(details);
  }

  Map<String, String> extractInstallerDetails(Map<String, String> infos, AppLocalizations locale) {
    return extractDetails(infos[Info.installer.key(locale)]!
        .split('\n')
        .map((String line) => line.trim())
        .toList());
  }

  List<String> extractTags(Map<String, String> infos, AppLocalizations locale) {
    List<String> split = infos[Info.tags.key(locale)]!.split('\n');
    List<String> tags = [];
    for (String s in split) {
      if (s.isNotEmpty) {
        tags.add(s.trim());
      }
    }
    return tags;
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

  addLine(String line) {
    lines.add(line);
  }
}
