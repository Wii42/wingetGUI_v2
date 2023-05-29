import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/output_handling/loading_bar/loading_bar_part.dart';
import 'package:winget_gui/output_handling/scanner.dart';

import '../responsibility.dart';

class LoadingBarScanner extends Scanner {
  LoadingBarScanner(super.respList);

  @override
  void markResponsibleLines() {
    LoadingBarPart loadingBarPart = LoadingBarPart([]);
    for (Responsibility resp in respList) {
      if (resp.respPart == null) {
        if (resp.line.isProgressBar()) {
          resp.respPart = loadingBarPart;
        }
      }
    }
    if (respList.last.respPart == loadingBarPart) {
      loadingBarPart.addLine(respList.last.line);
    }
  }
}
