import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

class Content extends StatefulWidget {
  Content({super.key});

  late Function _rebuild;
  List<String> _command = ['help'];

  @override
  State<Content> createState() => _ContentState();

  void showResultOfCommand(List<String> command) {
    _command = command;
    _rebuild();
  }
}

class _ContentState extends State<Content> {
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
      future: _lineStream(),
      builder: (BuildContext context,
          AsyncSnapshot<Stream<List<String>>> processSnapshot) {
        if (processSnapshot.hasData) {
          return StreamBuilder<List<String>>(
            stream: processSnapshot.data,
            builder: (BuildContext context,
                AsyncSnapshot<List<String>> streamSnapshot) {
              return ListView(children: [
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (streamSnapshot.connectionState !=
                              ConnectionState.done)
                            const ProgressBar(),
                          if (streamSnapshot.hasData)
                            //for (String line in _splitLines(streamSnapshot.data!))
                            for (String line in streamSnapshot.data!)
                              Text(line),
                        ]))
              ]);
            },
          );
        } else if (processSnapshot.hasError) {
          return Text('Error: ${processSnapshot.error}');
        } else {
          return const ProgressBar();
        }
      },
    );
  }

  Future<Stream<List<String>>> _lineStream() async {
    Process p = await Process.start('winget', widget._command);
    Stream<String> singleDataStream = p.stdout.transform(utf8.decoder);
    Stream<String> splitUpStream = _createSplitUpStream(singleDataStream);
    return _createModifiedStream(splitUpStream);
  }

  Stream<List<String>> _createModifiedStream(Stream<String> originalStream) {
    final controller = StreamController<List<String>>();
    List<String> previousData = [];

    originalStream.listen((newData) {
      previousData.add(newData);
      controller.add(previousData);
    }, onDone: () {
      controller.close();
    });

    return controller.stream;
  }

  Stream<String> _createSplitUpStream(Stream<String> originalStream) {
    final controller = StreamController<String>();
    LineSplitter splitter = const LineSplitter();

    originalStream.listen((newData) {
      List<String> splitList = splitter.convert(newData);
      for (String string in splitList) {
        controller.add(string);
      }
    }, onDone: () {
      controller.close();
    });

    return controller.stream;
  }
}
