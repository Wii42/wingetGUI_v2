import 'package:fluent_ui/fluent_ui.dart';
import './process_output.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widget_assets/full_width_progress_bar.dart';
import '../widget_assets/pane_item_body.dart';

class OutputPage extends ProcessOutput {
  final String? title;

  const OutputPage({required super.process, super.key, this.title});

  @override
  Column buildPage(
      AsyncSnapshot<List<String>> streamSnapshot, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (streamSnapshot.connectionState != ConnectionState.done)
          const FullWidthProgressbar(),
        Expanded(
          child: PaneItemBody(
            title: title,
            process: process,
            child: processOutput(streamSnapshot, context),
          ),
        ),
      ],
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
