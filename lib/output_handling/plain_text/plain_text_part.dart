import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_list_extension.dart';

import '../../widget_assets/link_text.dart';
import '../output_part.dart';

class PlainTextPart extends OutputPart {
  PlainTextPart(super.lines);

  @override
  Widget? representation() {
    lines.trim();
    if (lines.isEmpty) {
      return null;
    }
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (String line in lines) LinkText(line: line),
        ],
      ),
    );
  }

  addLine(String line) {
    lines.add(line);
  }
}
