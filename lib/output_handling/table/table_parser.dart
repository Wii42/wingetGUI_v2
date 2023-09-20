import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/output_handling/output_builder.dart';
import 'package:winget_gui/output_handling/table/table_builder.dart';

import '../output_parser.dart';
import '../package_infos/package_attribute.dart';
import '../package_infos/package_infos_peek.dart';
import 'apps_table/package_list.dart';
import 'apps_table/package_short_info.dart';

typedef TableData = List<Map<String, String>>;

class TableParser extends OutputParser {
  final List<String> command;
  TableParser(super.lines, {required this.command});

  @override
  FlexibleOutputBuilder? parse(AppLocalizations wingetLocale) {
    TableData table = _makeTable();
    List<String> columnTitles = table.first.keys.toList();
    if (columnTitles.contains(PackageAttribute.name.key(wingetLocale)) &&
        columnTitles.contains(PackageAttribute.id.key(wingetLocale))) {
      return Either.b(QuickOutputBuilder((context) {
        List<PackageInfosPeek> packages = [
          for (Map<String, String> tableRow in table)
            PackageInfosPeek.fromMap(details: tableRow, locale: wingetLocale),
        ];
        return PackageList(packages, command: command);
      }));
    }

    return Either.b(TableBuilder(table));
  }

  TableData _makeTable() {
    List<int> columnsPos = _getColumnsPos();
    _correctLinesWithNonWesternGlyphs(columnsPos);
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

  void _correctLinesWithNonWesternGlyphs(List<int> columnsPos) {
    String line;
    for (int i = 2; i < lines.length; i++) {
      line = lines[i];
      bool test = line.containsNonWesternGlyphs();
      if (test) {
        Pattern pattern = RegExp(r"\s{2}[A-ZÄÖÜa-zäöü0-9]");
        Iterable<Match> matches = pattern.allMatches(line);
        if (matches.isEmpty) {
          return;
        }
        Match match = matches.first;
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
      infos[columnNames[i]] = (entry.substring(
              min(columnsPos[i], entry.length), min(end, entry.length)))
          .trim();
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
}
