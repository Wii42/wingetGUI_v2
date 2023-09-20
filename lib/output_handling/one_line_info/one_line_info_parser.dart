import 'dart:async';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_builder.dart';
import 'package:winget_gui/output_handling/output_builder.dart';
import 'package:winget_gui/output_handling/output_parser.dart';

import 'one_line_info_scanner.dart';

class OneLineInfoParser extends OutputParser {
  OneLineInfoParser(super.lines);

  @override
  FlexibleOutputBuilder? parse(AppLocalizations wingetLocale) =>
       Either.b(OneLineInfoBuilder(infos: extractInfos()));

  Map<String, String> extractInfos() {
    Map<String, String> infos = {};
    for (String line in lines) {
      List<String> parts = line.split(identifierSemicolon);
      if (parts.length == 1) {
        infos[parts.single.trim()] = '';
      } else {
        infos[parts[0].trim()] =
            parts.sublist(1).join(identifierSemicolon).trim();
      }
    }
    return infos;
  }
}
