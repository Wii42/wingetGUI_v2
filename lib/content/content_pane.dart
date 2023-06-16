import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/content/output_pane.dart';
import 'package:winget_gui/helpers/extensions/stream_modifier.dart';
import 'package:winget_gui/helpers/stack.dart';

import 'content_holder.dart';
import 'content_snapshot.dart';

class ContentPane extends StatefulWidget {
  late Function({bool goBack}) _rebuild;
  late List<String> _command;

  ContentPane({List<String>? command, super.key}) {
    _command = command ?? ['-?'];
  }

  @override
  State<ContentPane> createState() => _ContentPaneState();

  void showResultOfCommand(List<String> command, {String? title}) {
    _command = command;
    _rebuild();
  }

  List<String> get command => _command;

  void reload() {
    _rebuild();
  }

  void goBack() {
    _rebuild(goBack: true);
  }
}

class _ContentPaneState extends State<ContentPane> {
  final String winget = 'winget';

  late Process _process;
  bool _goBack = false;

  @override
  void initState() {
    super.initState();
    widget._rebuild = ({goBack = false}) {
      if (mounted) {
        setState(
          () {
            _goBack = goBack;
          },
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_goBack) {
      _loadPreviousStateFromStack();
    }
    return FutureBuilder<Stream<List<String>>>(
      future: getOutputStreamOfProcess(),
      builder: (BuildContext context,
          AsyncSnapshot<Stream<List<String>>> processSnapshot) {
        if (processSnapshot.hasData) {
          return OutputPane(
              stream: processSnapshot.data!, command: widget.command);
        } else if (processSnapshot.hasError) {
          return Text('Error: ${processSnapshot.error}');
        } else {
          return const ProgressBar();
        }
      },
    );
  }

  Future<Stream<List<String>>> getOutputStreamOfProcess() async {
    _process = await Process.start(winget, widget.command);
    Stream<String> stream = _process.stdout.transform(utf8.decoder);

    return stream
        .splitStreamElementsOnNewLine()
        .removeLoadingElementsFromStream()
        .rememberingStream();
  }

  _loadPreviousStateFromStack() {
    ListStack<ContentSnapshot> stack = ContentHolder.of(context).stack;
    if (stack.isNotEmpty) {
      ContentSnapshot prevState = stack.pop();
      if (stack.isNotEmpty) {
        prevState = stack.peek();
      }
      widget._command = prevState.command;
    }
    _goBack = false;
  }
}
