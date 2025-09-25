import 'output_parser.dart';

class Responsibility {
  final String line;
  OutputParser? respParser;

  Responsibility(this.line, {this.respParser});

  bool isHandled() => respParser != null;

  @override
  String toString() {
    return 'Responsibility(line: $line, respParser: $respParser)';
  }
}
