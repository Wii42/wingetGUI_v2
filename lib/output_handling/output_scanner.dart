import 'package:winget_gui/l10n/generated/app_localizations.dart';

import 'responsibility.dart';

abstract class OutputScanner {
  List<Responsibility> respList;

  OutputScanner(this.respList);

  void markResponsibleLines(AppLocalizations wingetLocale);
}
