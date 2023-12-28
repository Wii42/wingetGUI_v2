import 'dart:async';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/list/list_builder.dart';
import 'package:winget_gui/output_handling/output_builder.dart';
import 'package:winget_gui/output_handling/output_parser.dart';
import 'package:winget_gui/output_handling/parsed_output.dart';

class ListParser extends OutputParser {
  ListParser(super.lines);

  @override
  ParsedList parse(AppLocalizations wingetLocale) {
    String title = _retrieveTitle();
    Map<String, String> listEntries = _retrieveListEntries();
    return ParsedList(title: title, listEntries: listEntries);
  }

  String _retrieveTitle() {
    String title = lines[0];
    if (title.endsWith(':')) {
      title = title.substring(0, title.length - 1);
    }
    return title.trim();
  }

  Map<String, String> _retrieveListEntries() {
    List<String> listLines = lines.sublist(1).map((e) => e.trim()).toList();
    int splitPos = _findSplitInEntry(listLines);
    return _getListEntries(listLines, splitPos);
  }

  int _findSplitInEntry(List<String> lines) {
    Pattern pattern = RegExp("[ ][A-ZÄÖÜa-zäöü]");
    Iterable<Match> matches = pattern.allMatches(lines[0]);
    for (Match match in matches) {
      int pos = match.start;
      if (_areSpacesMatchingAtPos(pos, lines)) {
        return pos;
      }
    }
    return -1;
  }

  bool _areSpacesMatchingAtPos(int pos, List<String> lines) {
    for (String line in lines) {
      if (pos >= line.length) {
        return false;
        //throw Exception("pos $pos is out of bounds for line $line");
      }
      if (line[pos] != ' ') {
        return false;
      }
    }
    return true;
  }

  Map<String, String>_getListEntries(List<String> lines, int splitPos) {
    return {
      for (String line in lines)
        if (splitPos < 0)
          line.trim(): ''
        else
          line.substring(0, splitPos).trim(): line.substring(splitPos).trim()
    };
  }
}

class ParsedList extends ParsedOutput{
  String title;
  Map<String, String> listEntries;

  ParsedList({required this.title, required this.listEntries});

  @override
  ListBuilder widgetRepresentation() {
    return ListBuilder(title: title, list: listEntries);
  }



}
