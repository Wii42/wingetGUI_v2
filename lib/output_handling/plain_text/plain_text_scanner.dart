import 'package:winget_gui/output_handling/plain_text/plain_text_part.dart';

import '../responsibility.dart';
import '../scanner.dart';

class PlainTextScanner extends Scanner {
  PlainTextScanner(super.respList);
  @override
  void markResponsibleLines() {
    for (Responsibility resp in respList) {
      if (resp.respPart == null) {
        PlainTextPart rest = PlainTextPart([resp.line]);
        resp.respPart = rest;
      }
    }
  }
}
