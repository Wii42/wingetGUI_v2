import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/scroll_list_widget.dart';

import '../helpers/stack.dart';
import '../output_handling/output_handler.dart';
import 'content_holder.dart';
import 'content_snapshot.dart';

class OutputPane extends StatelessWidget {
  final Stream<List<String>> stream;
  final List<String> command;
  final String? title;

  const OutputPane(
      {required this.stream, required this.command, super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: stream,
      builder:
          (BuildContext context, AsyncSnapshot<List<String>> streamSnapshot) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (streamSnapshot.connectionState != ConnectionState.done)
              _progressBar(),
            if (streamSnapshot.hasData)
              FutureBuilder<List<Widget>>(
                future: _displayOutput(streamSnapshot.data!, context),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (streamSnapshot.connectionState ==
                        ConnectionState.done) {
                      _pushCurrentStateToStack(snapshot.data!, context);
                    }
                    return Expanded(
                      child: ScrollListWidget(
                        title: (command.firstOrNull != 'show') ? title : null,
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
          ],
        );
      },
    );
  }

  Future<List<Widget>> _displayOutput(
      List<String> output, BuildContext context) async {
    OutputHandler handler = OutputHandler(output,
        command: command, prevCommand: getPrevCommand(context));
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

  _pushCurrentStateToStack(List<Widget> widgets, BuildContext context) {
    ListStack<ContentSnapshot> stack = ContentHolder.of(context).stack;
    ContentSnapshot snapshot = ContentSnapshot(
        command: command, widgets: widgets, title: title ?? command.join(' '));

    if (stack.isNotEmpty && stack.peek().command == snapshot.command) {
      stack.pop();
    }
    stack.push(snapshot);
  }

  List<String>? getPrevCommand(BuildContext context) {
    ListStack<ContentSnapshot> stack = ContentHolder.of(context).stack;
    if (stack.isNotEmpty) {
      if (command != stack.peek().command) {
        return stack.peek().command;
      }
      if (stack.hasPeekUnder) {
        return stack.peekUnder().command;
      }
    }
    return null;
  }
}