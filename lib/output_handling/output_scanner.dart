import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'responsibility.dart';

abstract class OutputScanner {
  List<Responsibility> respList;

  OutputScanner(this.respList);

  void markResponsibleLines(AppLocalizations wingetLocale);
}
