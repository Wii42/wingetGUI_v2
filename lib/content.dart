import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/output_handler.dart';
import 'package:winget_gui/extensions/stream_modifier.dart';
import 'package:winget_gui/stack.dart';

class Content extends StatefulWidget {
  Content({List<String>? command, super.key}) {
    _command = command ?? ['-?'];
  }

  late Function({bool goBack, bool runCommand}) _rebuild;
  late List<String> _command;

  @override
  State<Content> createState() => _ContentState();

  void showResultOfCommand(List<String> command) {
    _command = command;
    _rebuild(runCommand: true);
  }

  List<String> get command => _command;

  void reload() {
    _rebuild(runCommand: true);
  }

  void goBack() {
    _rebuild(goBack: true, runCommand: false);
  }
}

class _ContentState extends State<Content> {
  late Process _process;
  ListStack<ContentSnapshot> stack = ListStack();
  bool _goBack = false;
  bool _runCommand = false;

  @override
  void initState() {
    super.initState();
    widget._rebuild = ({goBack = false, runCommand = false}) {
      setState(
        () {
          _goBack = goBack;
          _runCommand = runCommand;
        },
      );
    };
  }

  Future<Stream<List<String>>> getOutputStreamOfProcess() async {
    _process = await Process.start('winget', widget._command);
    Stream<String> stream = _process.stdout.transform(utf8.decoder);

    return stream
        .splitStreamElementsOnNewLine()
        .removeLoadingElementsFromStream()
        //.removeLoadingBarsFromStream()
        .rememberingStream();
  }

  @override
  Widget build(BuildContext context) {
    if (_goBack) {
      if (stack.isNotEmpty) {
        ContentSnapshot prevState = stack.pop();
        if (stack.isNotEmpty) {
          prevState = stack.peek();
        }
        widget._command = prevState.command;
      }
      _goBack = false;
    }
    if (!_runCommand) {
      if (stack.isNotEmpty) {
        ContentSnapshot state = stack.peek();

        widget._command = state.command;
        return _wrapInListView(state.widgets);
      }
    }
    _runCommand = false;
    return FutureBuilder<Stream<List<String>>>(
      future: getOutputStreamOfProcess(),
      builder: (BuildContext context,
          AsyncSnapshot<Stream<List<String>>> processSnapshot) {
        if (processSnapshot.hasData) {
          return _displayStreamOfOutput(processSnapshot.data!);
        } else if (processSnapshot.hasError) {
          return Text('Error: ${processSnapshot.error}');
        } else {
          return const ProgressBar();
        }
      },
    );
  }

  StreamBuilder<List<String>> _displayStreamOfOutput(
      Stream<List<String>> stream) {
    return StreamBuilder<List<String>>(
      stream: stream,
      builder:
          (BuildContext context, AsyncSnapshot<List<String>> streamSnapshot) {
        List<Widget> widgets = [];
        if (streamSnapshot.hasData) {
          widgets = _displayOutput(streamSnapshot.data!);
          if (streamSnapshot.connectionState == ConnectionState.done) {
            ContentSnapshot snapshot =
                ContentSnapshot(widget._command, widgets);

            if (stack.isNotEmpty && stack.peek().command == snapshot.command) {
              stack.pop();
            }
            stack.push(snapshot);
          }
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (streamSnapshot.connectionState != ConnectionState.done)
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SizedBox(
                      height: 0,
                      width: constraints.maxWidth,
                      child: const ProgressBar());
                },
              ),
            if (streamSnapshot.hasData)
              Expanded(child: _wrapInListView(widgets)),
          ],
        );
      },
    );
  }

  List<Widget> _displayOutput(List<String> output) {
    OutputHandler handler = OutputHandler(output, widget._command);
    handler.determineResponsibility();
    return handler.displayOutput();
  }

  Widget _wrapInListView(List<Widget> widgets) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: widgets),
        ),
      ],
    );
  }
}

class ContentSnapshot {
  List<String> command;
  List<Widget> widgets;

  ContentSnapshot(this.command, this.widgets);
}
