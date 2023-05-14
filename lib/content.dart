import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/stream_modifier.dart';

class Content extends StatefulWidget {
  Content({super.key});

  late Function _rebuild;
  List<String> _command = ['--help'];

  @override
  State<Content> createState() => _ContentState();

  void showResultOfCommand(List<String> command) {
    _command = command;
    _rebuild();
  }

  void reload() {
    _rebuild();
  }
}

class _ContentState extends State<Content> {
  late Process _process;
  @override
  void initState() {
    super.initState();
    widget._rebuild = () {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
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

  Future<Stream<List<String>>> getOutputStreamOfProcess() async {
    _process = await Process.start('winget', widget._command);
    Stream<String> stream = _process.stdout.transform(utf8.decoder);

    return stream
        .splitStreamElementsOnNewLine()
        .removeLoadingElementsFromStream()
        .rememberingStream();
  }

  StreamBuilder<List<String>> _displayStreamOfOutput(
      Stream<List<String>> stream) {
    return StreamBuilder<List<String>>(
      stream: stream,
      builder:
          (BuildContext context, AsyncSnapshot<List<String>> streamSnapshot) {
        return ListView(children: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (streamSnapshot.connectionState != ConnectionState.done)
                      const ProgressBar(),
                    if (streamSnapshot.hasData)
                      ..._displayOutput(streamSnapshot.data!),
                  ]))
        ]);
      },
    );
  }

  List<Widget> _displayOutput(List<String> output) {
    List<Widget> list = [for (String line in output) Text(line)];
    return list;
  }
}
