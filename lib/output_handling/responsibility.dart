import 'output_parser.dart';

class Responsibility {
  final String line;
  OutputParser? respParser;

  Responsibility(this.line, {this.respParser});

  bool isHandled() => respParser != null;
}
