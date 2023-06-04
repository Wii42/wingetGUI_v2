import 'package:winget_gui/output_handling/list/list_part.dart';
import 'package:winget_gui/output_handling/output_part.dart';
import 'package:winget_gui/output_handling/responsibility.dart';
import 'package:winget_gui/output_handling/scanner.dart';

class ListScanner extends Scanner {
  ListScanner(super.respList);

  @override
  void markResponsibleLines() {
    if (hasList()) {
      int start = _findListStart();
      int end = _findListEnd(start);
      _markLines(start, end);

      markResponsibleLines();
    }
  }

  int _findListStart() {
    for (int i = 0; i < respList.length; i++) {
      Responsibility resp = respList[i];
      if (!resp.isHandled() && resp.line.trim().endsWith(':')) {
        if (i + 1 < respList.length) {
          Responsibility nextResp = respList[i + 1];
          if (!nextResp.isHandled() && isPartOfList(nextResp.line)) {
            return i;
          }
        }
      }
    }
    return -1;
  }

  int _findListEnd(int start) {
    for (int i = start + 1; i < respList.length; i++) {
      Responsibility resp = respList[i];
      if (isPartOfList(resp.line)) {
        if (resp.isHandled()) {
          throw Exception('Line $i: Overlapping responsibilities');
        }
      } else {
        return i - 1;
      }
    }
    return respList.length - 1;
  }

  _markLines(int start, int end) {
    List<String> lines = [for (int i = start; i <= end; i++) respList[i].line];
    ListPart part = ListPart(lines);
    _setPartForLines(start, end, part);
  }

  _setPartForLines(int listStart, int listEnd, OutputPart part) {
    for (int i = listStart; i <= listEnd; i++) {
      respList[i].respPart = part;
    }
  }

  bool isPartOfList(String line) =>
      line.startsWith(' ') && line.trim().isNotEmpty;

  bool hasList() => _findListStart() > 0;
}
