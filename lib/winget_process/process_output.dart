import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/output_handler.dart';
import 'package:winget_gui/widget_assets/scroll_list_widget.dart';

import 'winget_process.dart';

abstract class ProcessOutput extends StatelessWidget {
  final WingetProcess process;

  const ProcessOutput({required this.process, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: process.outputStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<String>> streamSnapshot) {
        return buildPage(streamSnapshot, context);
      },
    );
  }

  List<Widget> outputList(
      AsyncSnapshot<List<String>> streamSnapshot, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return [
      if (streamSnapshot.hasData) onData(streamSnapshot, context),
      if (streamSnapshot.hasError) onError(streamSnapshot),
      if (isWaitingOnData(streamSnapshot)) onWaiting(locale),
    ];
  }

  Widget buildPage(
      AsyncSnapshot<List<String>> streamSnapshot, BuildContext context);

  Expanded onWaiting(AppLocalizations locale) {
    return Expanded(
      child: Center(
        child: Text(locale.waitOnData),
      ),
    );
  }

  bool isWaitingOnData(AsyncSnapshot<List<String>> streamSnapshot) {
    return !(streamSnapshot.hasData ||
        streamSnapshot.hasError ||
        streamSnapshot.connectionState == ConnectionState.done);
  }

  Center onError(AsyncSnapshot<List<String>> streamSnapshot) =>
      Center(child: Text(streamSnapshot.error.toString()));

  FutureBuilder<List<Widget>> onData(
      AsyncSnapshot<List<String>> streamSnapshot, BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: _displayOutput(streamSnapshot.data!, context,
          streamSnapshot.connectionState == ConnectionState.done),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Expanded(
            child: ScrollListWidget(
              listElements: snapshot.data!.withSpaceBetween(height: 10),
            ),
          );
        }
        if (snapshot.hasError) {
          if (snapshot.error is Error) {
            Error error = snapshot.error as Error;
            return Text('$error\n\n${error.stackTrace}');
          }

          return Text(snapshot.error.toString());
        }
        return const Center(
            child: ProgressRing(
          backgroundColor: Colors.transparent,
        ));
      },
    );
  }

  Future<List<Widget>> _displayOutput(
      List<String> output, BuildContext context, bool processIsFinished) async {
    OutputHandler handler = OutputHandler(output, command: process.command);
    AppLocalizations wingetLocale = OutputHandler.getWingetLocale(context);
    handler.determineResponsibility(wingetLocale);
    return outputRepresentationHook(handler, context, processIsFinished);
  }

  Future<List<Widget>> outputRepresentationHook(OutputHandler handler,
          BuildContext context, bool processIsFinished) =>
      handler.getRepresentation(context);
}
