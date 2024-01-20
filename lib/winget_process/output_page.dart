import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widget_assets/full_width_progress_bar_on_top.dart';
import '../widget_assets/pane_item_body.dart';
import './process_output.dart';

class OutputPage extends ProcessOutput {
  final String? title;

  const OutputPage({required super.process, super.key, this.title});

  @override
  Widget buildPage(
      AsyncSnapshot<List<String>> streamSnapshot, BuildContext context) {
    return FullWidthProgressBarOnTop(
      hasProgressBar:
      streamSnapshot.connectionState != ConnectionState.done,
      child: PaneItemBody(
        title: title,
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
