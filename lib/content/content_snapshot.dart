import 'package:fluent_ui/fluent_ui.dart';

class ContentSnapshot {
  List<String> command;
  List<Widget> widgets;
  String title;

  ContentSnapshot({required this.command, required this.widgets, required this.title});

  @override
  String toString() {
    return command.toString();
  }
}
