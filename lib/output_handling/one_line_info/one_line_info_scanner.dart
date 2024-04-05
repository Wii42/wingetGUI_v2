import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../output_parser.dart';
import '../output_scanner.dart';
import '../responsibility.dart';
import '../show/show_parser.dart';
import 'one_line_info_parser.dart';

const String identifierColon = ': ';

class OneLineInfoScanner extends OutputScanner {
  OneLineInfoScanner(super.respList);

  @override
  void markResponsibleLines(AppLocalizations wingetLocale) {
    OutputParser? prevPart;
    bool isSamePart = false;
    for (Responsibility resp in respList) {
      if (!resp.isHandled() &&
          resp.line.contains(identifierColon) &&
          resp.line.trim().indexOf(identifierColon) <= maxIdentifierLength) {
        if (isSamePart) {
          prevPart!.addLine(resp.line);
          resp.respParser = prevPart;
        } else {
          OutputParser rest = OneLineInfoParser([resp.line]);
          resp.respParser = rest;
          prevPart = rest;
          isSamePart = true;
        }
      } else {
        isSamePart = false;
      }
    }
  }
}
