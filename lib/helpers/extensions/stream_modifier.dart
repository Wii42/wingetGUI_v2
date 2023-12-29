import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';

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

  Stream<String> removeLeadingEmptyStringsFromStream() {
    final controller = StreamController<String>();

    bool isFirstData = true;
    listen((newData) {
      if (newData.isNotEmpty || !isFirstData) {
        controller.add(newData);
        isFirstData = false;
      }
    }, onDone: () {
      controller.close();
    });

    return controller.stream;
  }

  Stream<String> removeLoadingBarsFromStream() {
    final controller = StreamController<String>();

    listen((newData) {
      if (!newData.isProgressBar()) {
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

extension RemoveDuplicatesFromList<T extends List> on Stream<T> {
  Stream<T> removeDuplicates() {
    final controller = StreamController<T>();
    const ListEquality equality = ListEquality();
    T? previousData;

    listen((newData) {
      if (equality.equals(previousData, newData) == false) {
        previousData = newData;
        controller.add(newData);
      }
    }, onDone: () {
      controller.close();
    });

    return controller.stream;
  }
}
