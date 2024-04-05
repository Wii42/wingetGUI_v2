import 'dart:io';

import 'package:collection/collection.dart';
import 'package:cron/cron.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/helpers/version_or_string.dart';
import 'package:winget_gui/output_handling/output_handler.dart';
import 'package:winget_gui/output_handling/package_infos/package_id.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';
import 'package:winget_gui/widget_assets/favicon_db.dart';

import 'db_message.dart';
import 'winget_table.dart';

class PackageTables {
  late final Logger log;
  DBStatus status = DBStatus.loading;
  static final PackageTables instance = PackageTables._();
  late WingetTable updates, installed, available;
  List<WingetTable> get tables => [updates, installed, available];

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

    installed = FaviconDB.instance.installed.parent;
    updates = FaviconDB.instance.updates.parent;
    available = FaviconDB.instance.available.parent;
    installed.reloadFuture(wingetLocale);
    updates.reloadFuture(wingetLocale);
    available.reloadFuture(wingetLocale);
    status = DBStatus.ready;
    scheduleReloadDBs(wingetLocale);
    return;
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

  static List<PackageInfosPeek> filterUpdates(infos) {
    List<PackageInfosPeek> toRemoveFromUpdates = [];
    for (PackageInfosPeek package in infos) {
      PackageId id = package.id!.value;
      if (PackageTables.instance.installed.idMap.containsKey(id)) {
        List<PackageInfosPeek> installedPackages =
            PackageTables.instance.installed.idMap[id]!;
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
    return PackageTables.instance.installed.idMap
        .containsKey(package.id?.value);
  }

  static bool isPackageUpgradable(PackageInfosPeek package) =>
      package.availableVersion != null &&
      package.availableVersion!.value.isVersion();

  static Future<bool> checkWingetAvailable() async {
    ProcessResult result = await Process.run('where', ['winget']);
    return result.exitCode == 0;
  }

  void reloadDBs(AppLocalizations wingetLocale) {
    for (WingetTable table in tables) {
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
