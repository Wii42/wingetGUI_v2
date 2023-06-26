import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/output_handling/table/table_part.dart';

import '../output_part.dart';
import '../responsibility.dart';
import '../scanner.dart';

class TableScanner extends Scanner {
  TableScanner(super.respList);

  @override
  void markResponsibleLines(BuildContext context) {
    if (hasTable()) {
      _makeTable();
      markResponsibleLines(context);
    }
  }

  bool hasTable() {
    int posHorizontalLine = _findHorizontalLine();
    if (posHorizontalLine < 0) {
      //found none
      return false;
    }
    Responsibility prevLine = respList[posHorizontalLine - 1];
    Responsibility nextLine = respList[posHorizontalLine + 1];
    return (_couldBePartOfTable(prevLine) && _couldBePartOfTable(nextLine));
  }

  bool _couldBePartOfTable(Responsibility resp) {
    return (!resp.isHandled() && resp.line.trim().isNotEmpty);
  }

  int _findHorizontalLine() {
    for (int i = 0; i < respList.length; i++) {
      Responsibility resp = respList[i];
      if (resp.line.contains('-----') && !resp.isHandled()) {
        return i;
      }
    }
    return -1;
  }

  _makeTable() {
    int tableStart = _findHorizontalLine() - 1;
    int tableEnd = _findTableEnd(tableStart);

    if (_linesAvailable(tableStart, tableEnd)) {
      List<String> tableLines = [
        for (int i = tableStart; i <= tableEnd; i++) respList[i].line
      ];
      _markLines(tableStart, tableEnd, TablePart(tableLines));
    }
  }

  int _findTableEnd(int tableStart) {
    String firstLine = respList[tableStart].line;
    int lastindexOfIdentifier = firstLine.lastIndexOf(' ');
    Responsibility resp;
    for (int i = tableStart + 2; i < respList.length; i++) {
      resp = respList[i];
      String line = resp.line;

      if (line.length != firstLine.length) {
        // no idea why this works
        if (line.length > lastindexOfIdentifier + 10) {
          if (!line.contains('…')) {
            return i - 1;
          }
        }
      }

      if ((line.lastIndexOf(' ') != lastindexOfIdentifier)) {
        if (line.containsNonWesternGlyphs()) {
          if (!line.contains(RegExp("[ ][A-ZÄÖÜa-zäöü0-9]"))) {
            return i - 1;
          }
        } else {
          return i - 1;
        }
      }
    }
    return respList.length - 1;
  }

  bool _linesAvailable(int tableStart, int tableEnd) {
    for (int i = tableStart; i <= tableEnd; i++) {
      if (respList[i].isHandled()) {
        throw Exception('bad marking');
      }
    }
    return true;
  }

  _markLines(int tableStart, int tableEnd, OutputPart part) {
    for (int i = tableStart; i <= tableEnd; i++) {
      respList[i].respPart = part;
    }
  }
}
