import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/output_handling/table/table_builder.dart';

import '../output_parser.dart';
import '../package_infos/package_attribute.dart';
import '../package_infos/package_infos_peek.dart';
import '../parsed_output.dart';
import 'apps_table/package_list.dart';

typedef TableData = List<Map<String, String>>;

class TableParser extends OutputParser {
  final List<String> command;
  TableParser(super.lines, {required this.command});

  @override
  Future<ParsedTable> parse(AppLocalizations wingetLocale) async {
    TableData table = await Isolate.run<TableData>(_makeTable);
    if (isAppTable(table, wingetLocale)) {
      List<PackageInfosPeek> packages = [
        for (Map<String, String> tableRow in table)
          PackageInfosPeek.fromMap(details: tableRow, locale: wingetLocale),
      ];

      return ParsedAppTable(table, packages: packages, command: command);
    }

    return ParsedTable(table);
  }

  TableData _makeTable() {
    List<int> columnsPos = _getColumnsPos();
    _correctLinesWithCjKIdeographs(columnsPos);
    return _extractTableData(columnsPos);
  }

  List<int> _getColumnsPos() {
    String head = lines[0];
    Pattern pattern;
    if (head.trim().contains(RegExp(r"\s{2,}"))) {
      pattern = RegExp(r"\s+[A-ZÄÖÜ]");
    } else {
      pattern = RegExp(r"\s{2,}[A-ZÄÖÜ]");
    }

    Iterable<Match> matches = pattern.allMatches(head);
    List<int> columnsPos = [0, for (Match match in matches) match.end - 1];

    List<int> additionalColumns = _findNoNameColumns(lines[2], columnsPos);
    if (additionalColumns.isNotEmpty) {
      columnsPos.addAll(additionalColumns);
      columnsPos = columnsPos.toSet().toList();
      columnsPos.sort();
    }

    return columnsPos;
  }

  void _correctLinesWithCjKIdeographs([List<int>? columnsPos]) {
    for (int i = 2; i < lines.length; i++) {
      String line = lines[i];
      bool test = line.containsCjkIdeograph();
      if (test) {
        if (line.startsWith('CeVIO')) {
          //bodge because only packages starting with cevio seem to not be parsed correctly due to cjk chars
          List<String> words = line.split('  ');
          for (int j = 0; j < words.length; j++) {
            String word = words[j];
            if (word.containsCjkIdeograph()) {
              if (line.startsWith('CeVIO Voice Package - 東北きりたん')) {
                word = (word) + ('  ' * (word.countCjkIdeographs() + 2));
              } else {
                word = (word) + ('  ' * word.countCjkIdeographs());
              }
            }
            words[j] = word;
          }
          line = words.join('  ');
        } else {
          List<String> words = line.split(' ');
          for (int j = 0; j < words.length; j++) {
            String word = words[j];
            if (word.containsCjkIdeograph()) {
              word = (word) + (' ' * word.countCjkIdeographs());
            }
            words[j] = word;
          }
          line = words.join(' ');
        }
      }
      lines[i] = line;
    }
  }

  List<Map<String, String>> _extractTableData(List<int> columnsPos) {
    List<String> columnNames = _getColumnNames(columnsPos);

    List<String> body = lines.sublist(2);
    List<Map<String, String>> tableData = [];

    for (String entry in body) {
      Map<String, String> infos =
          _getDictFromLine(entry, columnNames, columnsPos);
      tableData.add(infos);
    }
    return tableData;
  }

  Map<String, String> _getDictFromLine(
      String entry, List<String> columnNames, List<int> columnsPos) {
    Map<String, String> infos = {};
    for (int i = 0; i < columnNames.length; i++) {
      int end = i + 1 < columnNames.length ? columnsPos[i + 1] : entry.length;
      String tableCell = (entry.substring(
          min(columnsPos[i], entry.length), min(end, entry.length)));
      if (tableCell.isNotEmpty) {
        if (tableCell.lastChar() != ' ') {
          int nextCharIndex = end;
          while (nextCharIndex < entry.length &&
              entry.charAt(nextCharIndex) != ' ') {
            tableCell = tableCell + entry.charAt(nextCharIndex);
            nextCharIndex++;
          }
        }
      }
      infos[columnNames[i]] = tableCell.trim();
    }
    return infos;
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

  List<int> _findNoNameColumns(String testedLine, List<int> alreadyKnownCols) {
    testedLine = testedLine.trim();

    List<String> body = lines.sublist(2);
    Pattern pattern = RegExp(r"\s{3,}");

    List<int> additionalPos = [];
    Iterable<Match> matches = pattern.allMatches(testedLine);
    List<int> possibleColumnsPos = [for (Match match in matches) match.end];
    for (int possiblePos in possibleColumnsPos) {
      if (!alreadyKnownCols.contains(possiblePos) &&
          body.every((line) =>
              line.containsNonWesternGlyphs() ||
              (line.codeUnitAt(possiblePos - 1) == ' '.codeUnits.first))) {
        additionalPos.add(possiblePos);
      }
    }
    return additionalPos;
  }

  bool isAppTable(TableData table, AppLocalizations wingetLocale) {
    List<String> columnTitles = table.first.keys.toList();
    return columnTitles.contains(PackageAttribute.name.key(wingetLocale)) &&
        columnTitles.contains(PackageAttribute.id.key(wingetLocale));
  }
}

class ParsedTable extends ParsedOutput {
  TableData table;
  ParsedTable(this.table);

  bool isAppTable() => false;

  @override
  List<Widget?> singleLineRepresentations() {
    return [TableBuilder(table)];
  }
}

class ParsedAppTable extends ParsedTable {
  List<PackageInfosPeek> packages;
  List<String> command;

  ParsedAppTable(super.table, {required this.packages, required this.command});

  @override
  bool isAppTable() => true;

  @override
  String toString() {
    return "ParsedAppTable{command: $command, ${packages.length} entries}";
  }

  @override
  List<Widget?> singleLineRepresentations() {
    return [PackageList(packages, command: command)];
  }
}
