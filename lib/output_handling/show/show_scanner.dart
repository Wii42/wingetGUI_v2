import 'package:winget_gui/output_handling/scanner.dart';
import 'package:winget_gui/output_handling/show/show_part.dart';

class ShowScanner extends Scanner {
  List<String> command;
  ShowScanner(super.respList, this.command);

  @override
  void markResponsibleLines() {
    if (respList.isEmpty || command.isEmpty || command[0] != 'show') {
      return;
    }
    int identifierPos = _findIdentifier();
    if (identifierPos > -1) {
      ShowPart showPart = ShowPart([]);
      for (int i = identifierPos; i < respList.length; i++) {
        if (respList[i].respPart != null) {
          break;
        }
        showPart.addLine(respList[i].line);
        respList[i].respPart = showPart;
      }
    }
  }

  int _findIdentifier() {
    for (int i = 0; i < respList.length; i++) {
      if (respList[i].respPart == null && _isIdentifier(respList[i].line)) {
        return i;
      }
    }
    return -1;
  }

  bool _isIdentifier(String line) {
    line = line.trim();
    if (!line.startsWith('Gefunden')) {
      return false;
    }
    line = line.toLowerCase();
    if (command.contains('--id')) {
      String id = command[command.indexOf('--id') + 1].toLowerCase();
      return (line.endsWith('[$id]'));
    }

    if (command.contains('--name')) {
      String name = command[command.indexOf('--name') + 1].toLowerCase();
      return (line.contains(name));
    }

    String? name = _findNameInCommand()?.toLowerCase();
    if (name != null) {
      return (line.contains(name) || line.endsWith('[$name]'));
    }

    return false;
  }

  String? _findNameInCommand() {
    bool prevWasNotOption = false;
    for (int i = 0; i < command.length; i++) {
      bool isNotOption = !command[i].trim().startsWith('-');
      if (prevWasNotOption && isNotOption) {
        return command[i];
      }
      prevWasNotOption = isNotOption;
    }
    return null;
  }
}
