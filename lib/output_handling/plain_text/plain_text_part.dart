import 'package:fluent_ui/fluent_ui.dart';

import '../output_part.dart';

class PlainTextPart extends OutputPart {
  PlainTextPart(super.lines);

  @override
  Widget representation() {
    return Column(children: [for (String line in lines) Text(line)]);
  }
}
