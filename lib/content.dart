import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/output_handler.dart';
import 'package:winget_gui/extensions/stream_modifier.dart';
import 'package:winget_gui/stack.dart';

import 'content_place.dart';

class Content extends StatefulWidget {
  Content({List<String>? command, super.key}) {
    _command = command ?? ['-?'];
  }

  late Function({bool goBack, bool runCommand, String? title}) _rebuild;
  late List<String> _command;

  @override
  State<Content> createState() => _ContentState();

  void showResultOfCommand(List<String> command, {String? title}) {
    _command = command;
    _rebuild(runCommand: true, title: title);
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
  bool _goBack = false;
  bool _runCommand = false;
  String? _title;

  @override
  void initState() {
    super.initState();
    widget._rebuild = ({goBack = false, runCommand = false, String? title}) {
      setState(
        () {
          _goBack = goBack;
          _runCommand = runCommand;
          _title = title;
          print('manual rebuild');
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
    print("run command: $_runCommand");
    ListStack<ContentSnapshot> stack = ContentPlace.of(context).stack;
    if (_goBack) {
      if (stack.isNotEmpty) {
        ContentSnapshot prevState = stack.pop();
        if (stack.isNotEmpty) {
          prevState = stack.peek();
        }
        widget._command = prevState.command;
        _goBack = false;
        return _wrapInListView(prevState.widgets);
      }
      _goBack = false;
    }
    if (!_runCommand) {
      if (stack.isNotEmpty) {
        ContentSnapshot state = stack.peek();

        widget._command = state.command;
        print('no run');
        //_runCommand = false;
        //return _wrapInListView(state.widgets);
      }
    }
    print(stack);
    //_runCommand = false;
    return FutureBuilder<Stream<List<String>>>(
      future: getOutputStreamOfProcess(),
      builder: (BuildContext context,
          AsyncSnapshot<Stream<List<String>>> processSnapshot) {
        if (processSnapshot.hasData) {
          return _displayStreamOfOutput(processSnapshot.data!, context);
        } else if (processSnapshot.hasError) {
          return Text('Error: ${processSnapshot.error}');
        } else {
          return const ProgressBar();
        }
      },
    );
  }

  StreamBuilder<List<String>> _displayStreamOfOutput(
      Stream<List<String>> stream, BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: stream,
      builder:
          (BuildContext context, AsyncSnapshot<List<String>> streamSnapshot) {
        List<Widget> widgets = [];
        if (streamSnapshot.hasData) {
          widgets = _displayOutput(streamSnapshot.data!, context);
          if (streamSnapshot.connectionState == ConnectionState.done) {
            ListStack<ContentSnapshot> stack = ContentPlace.of(context).stack;
            ContentSnapshot snapshot =
                ContentSnapshot(widget._command, widgets);

            if (stack.isNotEmpty && stack.peek().command == snapshot.command) {
              stack.pop();
            }
            stack.push(snapshot);
            print(stack);
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

  List<Widget> _displayOutput(List<String> output, BuildContext context) {
    OutputHandler handler = OutputHandler(output, widget._command, title: _title);
    handler.determineResponsibility();
    return handler.displayOutput(context);
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

  String toString(){
    return command.toString();
  }
}
