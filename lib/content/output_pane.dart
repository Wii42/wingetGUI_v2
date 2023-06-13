import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/scroll_list_widget.dart';

import '../helpers/stack.dart';
import '../output_handling/output_handler.dart';
import 'content_holder.dart';
import 'content_snapshot.dart';

class OutputPane extends StatelessWidget {
  final Stream<List<String>> stream;
  final List<String> command;

  const OutputPane({required this.stream, required this.command, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: stream,
      builder:
          (BuildContext context, AsyncSnapshot<List<String>> streamSnapshot) {
        List<Widget> widgets = [];
        if (streamSnapshot.hasData) {
          widgets = _displayOutput(streamSnapshot.data!, context);
          if (streamSnapshot.connectionState == ConnectionState.done) {
            _pushCurrentStateToStack(widgets, context);
          }
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (streamSnapshot.connectionState != ConnectionState.done)
              _progressBar(),
            if (streamSnapshot.hasData)
              Expanded(
                  child: ScrollListWidget(
                //title: command.join(" "),
                listElements: widgets,
              )),
          ],
        );
      },
    );
  }

  List<Widget> _displayOutput(List<String> output, BuildContext context) {
    OutputHandler handler = OutputHandler(output,
        command: command, prevCommand: getPrevCommand(context));
    handler.determineResponsibility();
    return handler.displayOutput();
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
    ContentSnapshot snapshot = ContentSnapshot(command, widgets);

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
