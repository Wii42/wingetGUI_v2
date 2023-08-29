import 'dart:isolate';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/output_handling/table/package_list.dart';
import 'package:winget_gui/output_handling/table/package_short_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../infos/package_infos.dart';
import '../output_part.dart';

class TablePart extends OutputPart {
  TablePart(super.lines, {required this.command, required this.locale});

  List<String> command;
  AppLocalizations locale;

  late PackageList packageList;

  @override
  Future<Widget?> representation(BuildContext context) async {
    packageList = await Isolate.run<PackageList>(_makeTable);
    return packageList;
  }

  PackageList _makeTable() {
    List<int> columnsPos = _getColumnsPos();
    _correctLinesWithNonWesternGlyphs(columnsPos);
    return _createPackageList(columnsPos);
  }

  List<int> _getColumnsPos() {
    Pattern pattern = RegExp("[ ][A-ZÄÖÜ]");
    String head = lines[0];

    Iterable<Match> matches = pattern.allMatches(head);
    return [0, for (Match match in matches) match.start];
  }

  void _correctLinesWithNonWesternGlyphs(List<int> columnsPos) {
    String line;
    for (int i = 2; i < lines.length; i++) {
      line = lines[i];
      bool test = line.containsNonWesternGlyphs();
      if (test) {
        Pattern pattern = RegExp("[ ]{2}[A-ZÄÖÜa-zäöü0-9]");
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

  PackageList _createPackageList(List<int> columnsPos) {
    List<String> columnNames = _getColumnNames(columnsPos);

    List<PackageShortInfo> packages = [];
    List<String> body = lines.sublist(2);
    for (String entry in body) {
      Map<String, String> infos =
          _getDictFromLine(entry, columnNames, columnsPos);
      packages.add(
        PackageShortInfo(
          PackageInfos.fromMap(details: infos, locale: locale),
          command: command,
        ),
      );
    }
    return PackageList(packages, command: command);
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
}
