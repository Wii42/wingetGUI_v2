import 'output_parser.dart';

class Responsibility {
  final String line;
  OutputParser? respPart;

  Responsibility(this.line, {this.respPart});

  bool isHandled() => respPart != null;
}
