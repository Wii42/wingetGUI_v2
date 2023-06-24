import 'package:fluent_ui/fluent_ui.dart';

abstract class OutputPart {
  List<String> lines;

  OutputPart(this.lines);

  Future<Widget?> representation(BuildContext context);

  addLine(String line) {
    lines.add(line);
  }
}
