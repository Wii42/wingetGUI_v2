import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/output_part.dart';

class LoadingBarPart extends OutputPart {
  LoadingBarPart(super.lines);

  @override
  Future<Widget?> representation(BuildContext context) async{
    if (lines.isEmpty) {
      return null;
    }
    return Text(lines.last.trim());
  }

  addLine(String line) {
    lines.add(line);
  }
}
