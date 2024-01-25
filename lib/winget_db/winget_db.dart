import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../output_handling/output_handler.dart';
import '../output_handling/package_infos/package_infos_peek.dart';
import '../winget_commands.dart';
import 'db_table.dart';
import 'db_table_creator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WingetDB {
  bool isInitialized = false;
  static final WingetDB instance = WingetDB._();
  late DBTable updates, installed, available;

  WingetDB._();

  Stream<String> init(BuildContext context) async* {
    AppLocalizations wingetLocale = OutputHandler.getWingetLocale(context);
    WidgetsFlutterBinding.ensureInitialized();

    DBTableCreator installedCreator = DBTableCreator(
        content: 'installed', winget: Winget.installed, parentDB: this);
    yield* installedCreator.init(wingetLocale);
    installed = installedCreator.returnTable();

    DBTableCreator updatesCreator = DBTableCreator(
        content: 'updates',
        winget: Winget.updates,
        filter: _filterUpdates,
        parentDB: this);
    yield* updatesCreator.init(wingetLocale);
    updates = updatesCreator.returnTable();

    DBTableCreator availableCreator = DBTableCreator(
        content: 'available', winget: Winget.availablePackages, parentDB: this);
    yield* availableCreator.init(wingetLocale);
    available = availableCreator.returnTable();

    isInitialized = true;
    return;
  }

  void printPublishersPackageNrs() {
    Map<String, List<PackageInfosPeek>> map = {};
    for (PackageInfosPeek package in available.infos) {
      String publisherId = package.probablyPublisherID()!;
      if (map.containsKey(publisherId)) {
        map[publisherId]!.add(package);
      } else {
        map[publisherId] = [package];
      }
    }

    map.entries
        .sorted((a, b) => b.value.length.compareTo(a.value.length))
        .forEach(
      (element) {
        // ignore: avoid_print
        print('${element.key}: ${element.value.length}');
      },
    );
  }

  List<PackageInfosPeek> _filterUpdates(infos) {
    List<PackageInfosPeek> toRemoveFromUpdates = [];
    for (PackageInfosPeek package in infos) {
      String id = package.id!.value;
      if (installed.idMap.containsKey(id)) {
        List<PackageInfosPeek> installedPackages = installed.idMap[id]!;
        List<String?> installedVersions =
            installedPackages.map((e) => e.version?.value).toList();
        if (installedVersions.contains(package.availableVersion?.value) ||
            installedVersions
                .contains("> ${package.availableVersion?.value}")) {
          toRemoveFromUpdates.add(package);
        }
      }
    }
    toRemoveFromUpdates.forEach(infos.remove);
    return infos;
  }

  void notifyListeners() {
    updates.notifyListeners();
    installed.notifyListeners();
    available.notifyListeners();
  }
}
