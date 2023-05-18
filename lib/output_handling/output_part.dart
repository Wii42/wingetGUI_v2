import 'package:fluent_ui/fluent_ui.dart';

abstract class OutputPart {
  List<String> lines;

  OutputPart(this.lines);

  Widget? representation();
}