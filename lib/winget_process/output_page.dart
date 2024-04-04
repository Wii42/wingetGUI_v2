import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/winget_process/winget_process.dart';

import '../widget_assets/full_width_progress_bar_on_top.dart';
import '../widget_assets/pane_item_body.dart';
import '../winget_commands.dart';
import './process_output.dart';

class OutputPage extends ProcessOutput {
  final String Function(AppLocalizations)? title;

  const OutputPage({required super.process, super.key, this.title});

  factory OutputPage.fromCommand(List<String> command, {String? title}) {
    return OutputPage(
        process: WingetProcess.fromCommand(command),
        title: title != null ? (_) => title : null);
  }
  factory OutputPage.fromWinget(Winget winget,
      {String? titleInput, List<String> parameters = const []}) {
    return OutputPage(
        process: WingetProcess.fromWinget(winget, parameters: parameters),
        title: (locale) => titleInput != null
            ? winget.titleWithInput(titleInput, localization: locale)
            : winget.title(locale));
  }

  @override
  Widget buildPage(
      AsyncSnapshot<List<String>> streamSnapshot, BuildContext context) {
    return FullWidthProgressBarOnTop(
      hasProgressBar: streamSnapshot.connectionState != ConnectionState.done,
      child: PaneItemBody(
        title: title != null ? title!(AppLocalizations.of(context)!) : null,
        process: process,
        child: processOutput(streamSnapshot, context),
      ),
    );
  }

  Column processOutput(
      AsyncSnapshot<List<String>> streamSnapshot, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: [
        ...outputList(streamSnapshot, context),
        if (streamSnapshot.connectionState != ConnectionState.done)
          stopButton(locale),
      ],
    );
  }

  Padding stopButton(AppLocalizations locale) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Button(
            onPressed: process.process.kill, child: Text(locale.endProcess)));
  }
}
