import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_builder.dart';
import 'package:winget_gui/output_handling/output_parser.dart';

import '../parsed_output.dart';
import 'one_line_info_scanner.dart';

//typedef OneLineInfo = ({String title, String details, InfoBarSeverity? severity});

class OneLineInfoParser extends OutputParser {
  OneLineInfoParser(super.lines);

  @override
  ParsedOneLineInfos parse(AppLocalizations wingetLocale) =>
      ParsedOneLineInfos(extractInfos(wingetLocale));

  List<OneLineInfo> extractInfos(AppLocalizations wingetLocale) {
    List<OneLineInfo> infos = [];
    for (String line in lines) {
      List<String> parts = line.split(identifierColon);
      if (parts.length == 1) {
        infos.add(OneLineInfo(
          title: parts.single.trim(),
          severity: determineSeverity(line.trim(), wingetLocale),
        ));
      } else {
        infos.add(OneLineInfo(
          title: parts[0].trim(),
          details: parts.sublist(1).join(identifierColon).trim(),
          severity: determineSeverity(line.trim(), wingetLocale),
        ));
      }
    }
    return infos;
  }

  InfoBarSeverity determineSeverity(
      String line, AppLocalizations wingetLocale) {
    if (line.startsWith('${wingetLocale.error} ')) {
      return InfoBarSeverity.warning;
    }
    if (line.startsWith('${wingetLocale.unexpectedError} ')) {
      return InfoBarSeverity.error;
    }
    return InfoBarSeverity.info;
  }
}

class ParsedOneLineInfos extends ParsedOutput {
  List<OneLineInfo> infos;

  ParsedOneLineInfos(this.infos);

  @override
  Widget widgetRepresentation() {
    return OneLineInfoBuilder(infos: infos);
  }
}

class OneLineInfo {
  final String title, details;
  final InfoBarSeverity severity;

  OneLineInfo(
      {required this.title,
      this.details = '',
      this.severity = InfoBarSeverity.info});
}
