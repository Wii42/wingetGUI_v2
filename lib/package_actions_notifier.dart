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
    notifyListeners();
  }

  void removeAll() {
    _actions.clear();
  }

  bool remove(PackageAction stream) {
    bool success = _actions.remove(stream);
    notifyListeners();
    return success;
  }
}

class PackageAction {
  PackageInfos? infos;
  PackageActionType? type;
  WingetProcess process;
  Key uniqueKey;
  PackageAction({required this.process, this.infos, this.type})
      : uniqueKey = UniqueKey();
}
