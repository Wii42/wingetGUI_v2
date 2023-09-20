import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_parser.dart';
import 'package:winget_gui/output_handling/responsibility.dart';
import 'package:winget_gui/output_handling/output_scanner.dart';
import 'package:winget_gui/output_handling/show/show_parser.dart';

import '../output_parser.dart';

const String identifierSemicolon = ': ';

class OneLineInfoScanner extends OutputScanner {
  OneLineInfoScanner(super.respList);

  @override
  void markResponsibleLines(BuildContext context) {
    OutputParser? prevPart;
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
          OutputParser rest = OneLineInfoParser([resp.line]);
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
