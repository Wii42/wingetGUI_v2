import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/string_extension.dart';

import 'output_handling.dart';

class TableScanner extends Scanner {
  TableScanner(super.respList);

  @override
  void markResponsibleLines() {
    if (hasTable()) {
      _makeTable();
      markResponsibleLines();
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
    return (resp.respPart == null && resp.line.trim().isNotEmpty);
  }

  int _findHorizontalLine() {
    for (int i = 0; i < respList.length; i++) {
      Responsibility resp = respList[i];
      if (resp.line.contains('-----') && resp.respPart == null) {
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
      if (respList[i].respPart != null) {
        throw Exception('bad marking');
        return false;
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

class TablePart extends OutputPart {
  TablePart(super.lines);
  late Table table;

  @override
  Widget representation() {
    _makeTable();
    return const Text('table');
  }

  _makeTable() {
    List<int> columnsPos = _getColumnsPos();
    _correctLinesWithNonWesternGlyphs(columnsPos);
    createTable(columnsPos);
  }

  List<int> _getColumnsPos() {
    Pattern pattern = RegExp("[ ][A-ZÄÖÜ]");
    String head = lines[0];

    Iterable<Match> matches = pattern.allMatches(head);
    return [for (Match match in matches) match.start];
  }

  void _correctLinesWithNonWesternGlyphs(List<int> columnsPos) {
    String line;
    for (int i = 2; i < lines.length; i++) {
      line = lines[i];
      bool test = line.containsNonWesternGlyphs();
      if (test) {
        Pattern pattern = RegExp("[ ]{2}[A-ZÄÖÜa-zäöü0-9]");
        Match match = pattern.allMatches(line).first;
        if (match.start + 2 < columnsPos[1]) {
          int diff = columnsPos[1] - (match.start + 2);
          String str = " " * diff + line;

          Pattern p = RegExp(" FLVCD.Bigrats ");

          if (p.allMatches(str).isNotEmpty) {
            str = " " * 2 + str;
          }
          lines[i] = str;
        }
      }
    }
  }

  void createTable(columnsPos) {
    List<String> columnNames = _getColumnNames(columnsPos);

    List<Map<String, String>> data = [];
    List<String> body = lines.sublist(2);
    for (String entry in body) {
      Map<String, String> infos = {};
      for (int i = 0; i < columnNames.length; i++) {
        int end = i + 1 < columnNames.length ? columnsPos[i + 1] : entry.length;
        infos[columnNames[i]] = (entry.substring(columnsPos[i], end)).trim();
      }
    }
    table = Table(columnNames,data);
  }

  List<String> _getColumnNames(List<int> columnsPos) {
    List<String> columnNames = [];
    int nrOfColumns = columnsPos.length;
    String head = lines[0];
    for (int i = 0; i < nrOfColumns; i++) {
      int end = i + 1 < nrOfColumns ? columnsPos[i + 1] : head.length;
      columnNames.add((head.substring(columnsPos[i], end)).trim());
    }
    return columnNames;
  }
}

class Table {
  List<String> columnNames;
  List<Map<String, String>> data;
  Table(this.columnNames, this.data);
}
