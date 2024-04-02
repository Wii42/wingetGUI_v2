import 'dart:async';
import 'dart:collection';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/winget_process/package_action_type.dart';
import 'package:winget_gui/winget_process/winget_process.dart';

import 'output_handling/package_infos/package_infos.dart';

class PackageActionsNotifier extends ChangeNotifier {
  final List<PackageAction> _actions = [];

  UnmodifiableListView<PackageAction> get actions =>
      UnmodifiableListView(_actions);

  void add(PackageAction stream) {
    _actions.add(stream);
    stream.listenForOutput(this);
    notifyListeners();
  }

  void removeAll() {
    for (var element in _actions) {
      element.stopListeningForOutput();
    }
    _actions.clear();
    notifyListeners();
  }

  bool remove(PackageAction stream) {
    bool success = _actions.remove(stream);
    stream.stopListeningForOutput();
    notifyListeners();
    return success;
  }

  void notify() {
    notifyListeners();
  }
}

class PackageAction {
  PackageInfos? infos;
  PackageActionType? type;
  WingetProcess process;
  Key uniqueKey;
  List<String> output = [];
  StreamSubscription<List<String>>? _outputSubscription;
  PackageAction({required this.process, this.infos, this.type})
      : uniqueKey = UniqueKey();

  void listenForOutput(PackageActionsNotifier notifier) {
    _outputSubscription = process.outputStream.listen((event) {
      output = event;
      notifier.notify();
    });
  }

  void stopListeningForOutput() {
    _outputSubscription?.cancel();
  }
}
