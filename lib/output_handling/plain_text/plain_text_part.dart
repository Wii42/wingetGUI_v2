import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/extensions/string_list_extension.dart';

import '../output_part.dart';

class PlainTextPart extends OutputPart {
  PlainTextPart(super.lines);

  @override
  Widget? representation() {
    lines.trim();
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
}
