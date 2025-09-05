import 'dart:async';
import 'dart:collection';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/winget_client/winget_command.dart';

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

  static PackageActionsNotifier of(BuildContext context) {
    return Provider.of<PackageActionsNotifier>(context, listen: false);
  }
}

class PackageAction {
  PackageInfos? infos;
  WingetPackageActionCommand wingetCommand;
  Stream<List<String>> commandOutputStream;
  Key uniqueKey;
  List<String> output = [];
  StreamSubscription<List<String>>? _outputSubscription;

  final Completer<int> _exitCodeCompleter = Completer<int>();

  PackageAction({
    required this.wingetCommand,
    this.infos,
    required this.commandOutputStream,
  }) : uniqueKey = UniqueKey();

  void listenForOutput(PackageActionsNotifier notifier) {
    _outputSubscription = commandOutputStream.listen(
      (event) {
        output = event;
        notifier.notify();
      },
      onDone: () => _exitCodeCompleter.complete(0),
      onError: (err) => _exitCodeCompleter.complete(1),
    );
  }

  void stopListeningForOutput() {
    _outputSubscription?.cancel();
  }

  Future<int> get exitCode => _exitCodeCompleter.future;
}
