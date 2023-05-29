import 'package:fluent_ui/fluent_ui.dart';

class ContentSnapshot {
  List<String> command;
  List<Widget> widgets;

  ContentSnapshot(this.command, this.widgets);

  @override
  String toString() {
    return command.toString();
  }
}
