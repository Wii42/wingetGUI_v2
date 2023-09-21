
import 'package:winget_gui/output_handling/plain_text/plain_text_parser.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../responsibility.dart';
import '../output_scanner.dart';

class PlainTextScanner extends OutputScanner {
  PlainTextScanner(super.respList);

  @override
  void markResponsibleLines(AppLocalizations wingetLocale) {
    PlainTextParser? prevPart;
    bool isSamePart = false;
    for (Responsibility resp in respList) {
      if (!resp.isHandled()) {
        if (isSamePart) {
          prevPart!.addLine(resp.line);
          resp.respPart = prevPart;
        } else {
          PlainTextParser rest = PlainTextParser([resp.line]);
          resp.respPart = rest;
          prevPart = rest;
          isSamePart = true;
        }
      } else {
        isSamePart = false;
      }
    }
  }
}
