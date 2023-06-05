import 'package:winget_gui/output_handling/one_line_info/one_line_info_part.dart';
import 'package:winget_gui/output_handling/responsibility.dart';
import 'package:winget_gui/output_handling/scanner.dart';
import 'package:winget_gui/output_handling/show/show_part.dart';

import '../output_part.dart';

const String identifierSemicolon = ': ';

class OneLineInfoScanner extends Scanner {
  OneLineInfoScanner(super.respList);

  @override
  void markResponsibleLines() {
    OutputPart? prevPart;
    bool isSamePart = false;
    for (Responsibility resp in respList) {
      if (!resp.isHandled() &&
          resp.line.contains(identifierSemicolon) &&
          resp.line.trim().indexOf(identifierSemicolon) <=
              maxIdentifierLength) {
        if (isSamePart) {
          prevPart!.addLine(resp.line);
          resp.respPart = prevPart;
        } else {
          OutputPart rest = OneLineInfoPart([resp.line]);
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
