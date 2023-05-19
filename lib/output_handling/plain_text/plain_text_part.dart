import 'package:fluent_ui/fluent_ui.dart';

import '../output_part.dart';

class PlainTextPart extends OutputPart {
  PlainTextPart(super.lines);

  @override
  Widget? representation() {
    _removeLeadingEmptyLines();
    _removeTrailingEmptyLines();
    if (lines.isEmpty) {
      return null;
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (String line in lines) Text(line)]);
  }

  addLine(String line) {
    lines.add(line);
  }

  _removeLeadingEmptyLines() {
    bool foundNotEmpty = false;
    while (!foundNotEmpty && lines.isNotEmpty) {
      String line = lines.first;
      if (line.trim().isEmpty) {
        lines.removeAt(0);
      }
      else{
        foundNotEmpty = true;
      }
    }
  }

  _removeTrailingEmptyLines() {
    bool foundNotEmpty = false;
    while (!foundNotEmpty && lines.isNotEmpty) {
      String line = lines.last;
      if (line.trim().isEmpty) {
        lines.removeLast();
      }
      else{
        foundNotEmpty = true;
      }
    }
  }
}
