import 'package:winget_gui/content/process_output.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../winget_process.dart';
import 'process_starter.dart';
import 'output_page.dart';

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
