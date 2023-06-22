import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/list/list_widget.dart';
import 'package:winget_gui/output_handling/output_part.dart';

class ListPart extends OutputPart {
  ListPart(super.lines);

  late String title;
  late Map<String, String> listEntries;

  @override
  Future<Widget?> representation() async{
    _retrieveTitle();
    _retrieveListEntries();
    return ListWidget(
      title: title,
      list: listEntries,
    );
  }

  _retrieveTitle() {
    String title = lines[0];
    if (title.endsWith(':')) {
      title = title.substring(0, title.length - 1);
    }
    this.title = title.trim();
  }

  _retrieveListEntries() {
    List<String> listLines = lines.sublist(1).map((e) => e.trim()).toList();
    int splitPos = _findSplitInEntry(listLines);
    _getListEntries(listLines, splitPos);
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
      if (line[pos] != ' ') {
        return false;
      }
    }
    return true;
  }

  _getListEntries(List<String> lines, int splitPos) {
    listEntries = {
      for (String line in lines)
        if (splitPos < 0)
          line.trim(): ''
        else
          line.substring(0, splitPos).trim(): line.substring(splitPos).trim()
    };
  }
}
