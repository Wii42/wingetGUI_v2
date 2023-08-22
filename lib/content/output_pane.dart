import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/widget_assets/scroll_list_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../output_handling/output_handler.dart';
import '../widget_assets/full_width_progress_bar.dart';
import '../winget_process.dart';

class OutputPane extends StatelessWidget {
  final WingetProcess process;
  final String? title;

  const OutputPane({required this.process, super.key, this.title});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return StreamBuilder<List<String>>(
      stream: process.outputStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<String>> streamSnapshot) {
        if (streamSnapshot.hasData) {
          print(streamSnapshot.data);
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (streamSnapshot.connectionState != ConnectionState.done)
              const FullWidthProgressbar(),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      icon: const Icon(FluentIcons.back)),
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: FluentTheme.of(context).typography.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  IconButton(
                    onPressed: () async {
                      NavigatorState navigator = Navigator.of(context);
                      WingetProcess newProcess = await process.clone();

                      navigator.pushReplacement(FluentPageRoute(
                          builder: (_) => OutputPane(process: newProcess, title: title,)));
                    },
                    icon: const Icon(FluentIcons.update_restore),
                  )
                ].withSpaceBetween(width: 10),
              ),
            ),
            if (streamSnapshot.hasData)
              FutureBuilder<List<Widget>>(
                future: _displayOutput(streamSnapshot.data!, context),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Expanded(
                      child: ScrollListWidget(
                        listElements: snapshot.data!,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return const Center(child: ProgressRing());
                },
              ),
            if (streamSnapshot.hasError)
              Center(child: Text(streamSnapshot.error.toString())),
            if (!(streamSnapshot.hasData ||
                streamSnapshot.hasError ||
                streamSnapshot.connectionState != ConnectionState.done))
              const Expanded(
                child: Center(
                  child: Text('waiting on data...'),
                ),
              ),
            if (streamSnapshot.connectionState != ConnectionState.done)
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Button(
                      onPressed: process.process.kill,
                      child: Text(locale.endProcess))),
          ],
        );
      },
    );
  }

  Future<List<Widget>> _displayOutput(
      List<String> output, BuildContext context) async {
    OutputHandler handler =
        OutputHandler(output, command: process.command, prevCommand: []);
    handler.determineResponsibility(context);
    return handler.displayOutput(context);
  }
}
