import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/scroll_list_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../helpers/stack.dart';
import '../output_handling/output_handler.dart';
import '../winget_process.dart';
import 'content_holder.dart';
import 'content_snapshot.dart';

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
              _progressBar(),
            if (title != null)
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  title!,
                  style: FluentTheme.of(context).typography.title,
                ),
              ),
            if (streamSnapshot.hasData)
              FutureBuilder<List<Widget>>(
                future: _displayOutput(streamSnapshot.data!, context),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    //if (streamSnapshot.connectionState ==
                    //    ConnectionState.done) {
                    //  _pushCurrentStateToStack(snapshot.data!, context);
                    //}
                    return Expanded(
                      child: ScrollListWidget(
                        listElements: snapshot.data!,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return _progressBar();
                },
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

  Widget _progressBar() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          height: 0,
          width: constraints.maxWidth,
          child: const ProgressBar(),
        );
      },
    );
  }

  //_pushCurrentStateToStack(List<Widget> widgets, BuildContext context) {
  //  ListStack<ContentSnapshot> stack = ContentHolder.of(context).stack;
  //  ContentSnapshot snapshot = ContentSnapshot(
  //      command: process.command,
  //      widgets: widgets,
  //      title: title ?? process.command.join(' '));
  //
  //  if (stack.isNotEmpty && stack.peek().command == snapshot.command) {
  //    stack.pop();
  //  }
  //  stack.push(snapshot);
  //}

  //List<String>? getPrevCommand(BuildContext context) {
  //  ListStack<ContentSnapshot> stack = ContentHolder.of(context).stack;
  //  if (stack.isNotEmpty) {
  //    if (process.command != stack.peek().command) {
  //      return stack.peek().command;
  //    }
  //    if (stack.hasPeekUnder) {
  //      return stack.peekUnder().command;
  //    }
  //  }
  //  return null;
  //}
}
