import 'dart:async';

import 'package:winget_gui/l10n/generated/app_localizations.dart';

import 'parsed_output.dart';

abstract class OutputParser {
  List<String> lines;

  OutputParser(this.lines);

  FutureOr<ParsedOutput> parse(AppLocalizations wingetLocale);

  addLine(String line) {
    lines.add(line);
  }
}
