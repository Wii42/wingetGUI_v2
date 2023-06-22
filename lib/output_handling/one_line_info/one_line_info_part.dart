import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_widget.dart';
import 'package:winget_gui/output_handling/output_part.dart';

import 'one_line_info_scanner.dart';

class OneLineInfoPart extends OutputPart {
  OneLineInfoPart(super.lines);

  @override
  Future<Widget?> representation() async{
    return OneLineInfoWidget(infos: extractInfos());
  }

  Map<String, String> extractInfos() {
    Map<String, String> infos = {};
    for (String line in lines) {
      List<String> parts = line.split(identifierSemicolon);
      if (parts.length == 1) {
        infos[parts.single.trim()] = '';
      } else {
        infos[parts[0].trim()] =
            parts.sublist(1).join(identifierSemicolon).trim();
      }
    }
    return infos;
  }
}
