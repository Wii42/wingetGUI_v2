import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';

import '../output_scanner.dart';
import '../responsibility.dart';
import 'loading_bar_parser.dart';

class LoadingBarScanner extends OutputScanner {
  LoadingBarScanner(super.respList);

  @override
  void markResponsibleLines(AppLocalizations wingetLocale) {
    LoadingBarParser loadingBarParser = LoadingBarParser([]);
    bool isNewLoadingBar = true;
    for (Responsibility resp in respList) {
      if (!resp.isHandled() && resp.line.isProgressBar()) {
        if (isNewLoadingBar) {
          loadingBarParser = LoadingBarParser([]);
          isNewLoadingBar = false;
        }
        resp.respParser = loadingBarParser;
        loadingBarParser.addLine(resp.line);
      } else {
        isNewLoadingBar = true;
      }
    }
    //if (respList.last.respPart == loadingBarParser) {
    //  loadingBarParser.addLine(respList.last.line);
    //}
  }
}
