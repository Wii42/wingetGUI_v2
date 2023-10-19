import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './process_output.dart';
import 'output_page.dart';
import 'process_starter.dart';
import 'winget_process.dart';

class OutputPageStarter extends ProcessStarter {
  final String? titleInput;

  const OutputPageStarter(
      {super.key, required super.command, super.winget, this.titleInput});

  @override
  ProcessOutput processOutput(WingetProcess process, AppLocalizations locale) {
    return OutputPage(
        process: process,
        title: titleInput != null
            ? winget?.titleWithInput(titleInput!, localization: locale)
            : winget?.title(locale));
  }
}
