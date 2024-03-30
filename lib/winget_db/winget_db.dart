import 'dart:io';

import 'package:collection/collection.dart';
import 'package:cron/cron.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_parser.dart';

import '../helpers/log_stream.dart';
import '../helpers/version_or_string.dart';
import '../output_handling/output_handler.dart';
import '../output_handling/package_infos/package_id.dart';
import '../output_handling/package_infos/package_infos.dart';
import '../output_handling/package_infos/package_infos_peek.dart';
import '../widget_assets/favicon_db.dart';
import '../winget_commands.dart';
import 'db_message.dart';
import 'db_table.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PackageTables {
  late final Logger log;
  DBStatus status = DBStatus.loading;
  static final PackageTables instance = PackageTables._();
  late WingetDBTable updates, installed, available;
  List<WingetDBTable> get tables => [updates, installed, available];

  PackageTables._() {
    log = Logger(this);
  }

  Stream<LocalizedString> init(BuildContext context) async* {
    AppLocalizations wingetLocale = OutputHandler.getWingetLocale(context);
    WidgetsFlutterBinding.ensureInitialized();

    yield (locale) => locale.checkingWingetAvailability;
    bool isWingetAvailable = await checkWingetAvailable();
    if (!isWingetAvailable) {
      yield (locale) => locale.errorWingetNotAvailable;
      status = DBStatus.error;
      return;
    }

    installed = getDBTable(winget: Winget.installed);
    updates = getDBTable(winget: Winget.updates, creatorFilter: _filterUpdates);
    available = getDBTable(winget: Winget.availablePackages);
    installed.reloadFuture(wingetLocale);
    updates.reloadFuture(wingetLocale);
    available.reloadFuture(wingetLocale);
    //reloadDBs(wingetLocale);
    //printPublishersPackageNrs();
    status = DBStatus.ready;
    scheduleReloadDBs(wingetLocale);
    return;
  }

  WingetDBTable getDBTable({
    List<PackageInfosPeek> infos = const [],
    List<OneLineInfo> hints = const [],
    PackageFilter? creatorFilter,
    required Winget winget,
  }) {
    return WingetDBTable(
      infos,
      hints: hints,
      content: (locale) => locale.wingetTitle(winget.name),
      wingetCommand: winget.fullCommand,
      creatorFilter: creatorFilter,
      parent: this,
      parentDB: FaviconDB.instance,
      tableName: winget.name,
    );
  }

  bool isReady() => status == DBStatus.ready;

  void printPublishersPackageNrs() {
    Map<String, List<PackageInfosPeek>> map = {};
    for (PackageInfosPeek package in available.infos) {
      String publisherId = package.id!.value.probablyPublisherId()!;
      if (map.containsKey(publisherId)) {
        map[publisherId]!.add(package);
      } else {
        map[publisherId] = [package];
      }
    }
    log.info('Amount of packages per Publisher',
        message: map.entries
            .sorted((a, b) => b.value.length.compareTo(a.value.length))
            .map((e) => '${e.key}: ${e.value.length}')
            .join(('\n')));
  }

  List<PackageInfosPeek> _filterUpdates(infos) {
    List<PackageInfosPeek> toRemoveFromUpdates = [];
    for (PackageInfosPeek package in infos) {
      PackageId id = package.id!.value;
      if (installed.idMap.containsKey(id)) {
        List<PackageInfosPeek> installedPackages = installed.idMap[id]!;
        List<VersionOrString?> installedVersions =
            installedPackages.map((e) => e.version?.value).toList();
        if (installedVersions.any((e) =>
                e?.stringValue ==
                package.availableVersion?.value.stringValue) ||
            installedVersions.any((e) =>
                e?.stringValue ==
                "> ${package.availableVersion?.value.stringValue}")) {
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

  static bool isPackageInstalled(PackageInfos package) {
    if (package.id == null) return false;
    return PackageTables.instance.installed.idMap.containsKey(package.id?.value);
  }

  static bool isPackageUpgradable(PackageInfosPeek package) =>
      package.availableVersion != null &&
      package.availableVersion!.value.isVersion();

  static Future<bool> checkWingetAvailable() async {
    ProcessResult result = await Process.run('where', ['winget']);
    return result.exitCode == 0;
  }

  void reloadDBs(AppLocalizations wingetLocale) {
    for(WingetDBTable table in tables) {
      table.reloadFuture(wingetLocale);
    }
  }

  void scheduleReloadDBs(AppLocalizations wingetLocale) {
    Cron cron = Cron();
    cron.schedule(Schedule(hours: '*/1'), () {
      reloadDBs(wingetLocale);
    });
  }
}
