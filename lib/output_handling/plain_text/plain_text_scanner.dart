import 'package:winget_gui/output_handling/plain_text/plain_text_part.dart';

import '../responsibility.dart';
import '../scanner.dart';

class PlainTextScanner extends Scanner {
  PlainTextScanner(super.respList);

  @override
  void markResponsibleLines() {
    PlainTextPart? prevPart;
    bool isSamePart = false;
    for (Responsibility resp in respList) {
      if (resp.respPart == null) {
        if (isSamePart) {
          prevPart!.addLine(resp.line);
          resp.respPart = prevPart;
        } else {
          PlainTextPart rest = PlainTextPart([resp.line]);
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
