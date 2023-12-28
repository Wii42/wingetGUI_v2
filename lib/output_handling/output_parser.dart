import 'dart:async';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/output_builder.dart';
import 'package:winget_gui/output_handling/parsed_output.dart';

abstract class OutputParser {
  List<String> lines;


  OutputParser(this.lines);

  FutureOr<ParsedOutput> parse(AppLocalizations wingetLocale);

  addLine(String line) {
    lines.add(line);
  }
}
