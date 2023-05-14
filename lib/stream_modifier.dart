import 'dart:async';
import 'dart:convert';

import 'package:winget_gui/string_extension.dart';

extension StringStreamModifier on Stream<String> {
  Stream<String> splitStreamElementsOnNewLine() {
    final controller = StreamController<String>();
    LineSplitter splitter = const LineSplitter();

    listen((newData) {
      List<String> splitList = splitter.convert(newData);
      for (String string in splitList) {
        controller.add(string);
      }
    }, onDone: () {
      controller.close();
    });

    return controller.stream;
  }

  Stream<String> removeLoadingElementsFromStream() {
    final controller = StreamController<String>();

    listen((newData) {
      if (!newData.isLoadingSymbols()) {
        controller.add(newData);
      }
    }, onDone: () {
      controller.close();
    });

    return controller.stream;
  }
}

extension RememberingStream<T> on Stream<T> {
  /// return a Stream of Lists of the original type,
  /// which contains all previous Data in the Stream
  Stream<List<T>> rememberingStream() {
    final controller = StreamController<List<T>>();
    List<T> previousData = [];

    listen((newData) {
      previousData.add(newData);
      controller.add(previousData);
    }, onDone: () {
      controller.close();
    });

    return controller.stream;
  }
}
