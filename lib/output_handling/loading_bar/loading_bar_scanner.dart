
import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/output_handling/loading_bar/loading_bar_parser.dart';
import 'package:winget_gui/output_handling/output_scanner.dart';

import '../responsibility.dart';

class LoadingBarScanner extends OutputScanner {
  LoadingBarScanner(super.respList);

  @override
  void markResponsibleLines(BuildContext context) {
    LoadingBarParser loadingBarPart = LoadingBarParser([]);
    for (Responsibility resp in respList) {
      if (!resp.isHandled()) {
        if (resp.line.isProgressBar()) {
          resp.respPart = loadingBarPart;
          loadingBarPart.addLine(resp.line);

        }
      }
    }
    //if (respList.last.respPart == loadingBarPart) {
    //  loadingBarPart.addLine(respList.last.line);
    //}
  }
}
