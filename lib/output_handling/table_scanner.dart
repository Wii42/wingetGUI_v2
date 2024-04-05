import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';

import 'output_parser.dart';
import 'output_scanner.dart';
import 'responsibility.dart';
import 'table_parser.dart';

class TableScanner extends OutputScanner {
  final List<String> command;
  List<int> falsePositives = [];

  TableScanner(super.respList, {required this.command});

  @override
  void markResponsibleLines(AppLocalizations wingetLocale) {
    if (hasTable()) {
      _makeTable();
      markResponsibleLines(wingetLocale);
    }
    falsePositives = [];
  }

  bool hasTable() {
    int posHorizontalLine = _findHorizontalLine();
    if (posHorizontalLine < 0) {
      //found none
      return false;
    }

    bool isFalsePositive = false;

    Responsibility prevLine = respList[posHorizontalLine - 1];
    Responsibility nextLine = respList[posHorizontalLine + 1];
    if (!(_couldBePartOfTable(prevLine) && _couldBePartOfTable(nextLine))) {
      isFalsePositive = true;
    }

    if (isFalsePositive) {
      falsePositives.add(posHorizontalLine);
      return hasTable();
    }
    return true;
  }

  bool _couldBePartOfTable(Responsibility resp) {
    return (!resp.isHandled() && resp.line.trim().isNotEmpty);
  }

  int _findHorizontalLine() {
    for (int i = 0; i < respList.length; i++) {
      Responsibility resp = respList[i];
      if (resp.line.contains('-----') &&
          !resp.isHandled() &&
          !falsePositives.contains(i)) {
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
      _markLines(
          tableStart, tableEnd, TableParser(tableLines, command: command));
    }
  }

  int _findTableEnd(int tableStart) {
    String firstLine = respList[tableStart].line;

    if (!firstLine.trim().contains(RegExp(r'\s{2,}'))) {
      Responsibility resp;
      for (int i = tableStart + 2; i < respList.length; i++) {
        resp = respList[i];
        if (resp.respParser != null || resp.line.isEmpty) {
          return i - 1;
        }
      }
      return respList.length - 1;
    }

    int lastindexOfIdentifier = firstLine.lastIndexOf(' ');
    Responsibility resp;
    for (int i = tableStart + 2; i < respList.length; i++) {
      resp = respList[i];
      String line = resp.line;

      if (line.length != firstLine.length) {
        // no idea why this works
        if (line.length > lastindexOfIdentifier + 10 &&
            (line.codeUnitAt(lastindexOfIdentifier) != ' '.codeUnits.first)) {
          if (!line.contains('…')) {
            return i - 1;
          }
        }
      }

      if ((line.lastIndexOf(' ') != lastindexOfIdentifier)) {
        if (line.containsNonWesternGlyphs()) {
          if (!line.contains(RegExp(r"[A-ZÄÖÜa-zäöü0-9]"))) {
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

  _markLines(int tableStart, int tableEnd, OutputParser part) {
    for (int i = tableStart; i <= tableEnd; i++) {
      respList[i].respParser = part;
    }
  }
}
