import 'dart:io';

import 'package:collection/collection.dart';
import 'package:cron/cron.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:persistent_storage_interface/interface.dart';
import 'package:persistent_storage_interface/service.dart';
import 'package:provider/provider.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/output_handling/one_line_info_parser.dart';
import 'package:winget_gui/package_infos/package_infos_extension.dart';

import '../winget_client/winget_client.dart';
import '../winget_client/winget_command.dart';
import 'db_message.dart';
import 'winget_table.dart';

class PackageTables {
  late final Logger log;
  DBStatus status = DBStatus.loading;
  static final PackageTables instance = PackageTables._();
  late WingetTable updates, installed, available;

  List<WingetTable> get tables => [updates, installed, available];

  bool _isInitialized = false;

  PackageTables._() {
    log = Logger(this);
  }

  Stream<LocalizedString> init(BuildContext context) async* {
    if (_isInitialized) {
      return;
    }
    WingetClient client  = context.read<WingetClient>();
    WidgetsFlutterBinding.ensureInitialized();

    yield (locale) => locale.checkingWingetAvailability;
    bool isWingetAvailable = await checkWingetAvailable();
    if (!isWingetAvailable) {
      yield (locale) => locale.errorWingetNotAvailable;
      status = DBStatus.error;
      return;
    }
    yield (locale) => 'Loading package tables from disk';
    PersistentStorageService storage = PersistentStorageService.instance;
    installed = await initTable(
      persistentStorage: storage.installedPackages,
      wingetCommand: CmdInstalled(),
    );
    updates = await initTable(
      persistentStorage: storage.updatePackages,
      wingetCommand: CmdUpdates(filter: filterUpdates),
    );
    available = await initTable(
      persistentStorage: storage.availablePackages,
      wingetCommand: CmdAvailablePackages(),
    );
    installed.reloadFuture(client);
    updates.reloadFuture(client);
    available.reloadFuture(client);
    status = DBStatus.ready;
    scheduleReloadDBs(client);
    _isInitialized = true;
    return;
  }

  Future<WingetTable> initTable({
    List<PackageInfosPeek> infos = const [],
    List<OneLineInfo> hints = const [],
    required BulkListStorage<PackageInfosPeek> persistentStorage,
    required WingetPackageListCommand wingetCommand,
  }) async {
    WingetTable wingetTable = WingetTable(
      infos,
      hints: hints,
      content: (locale) => locale.wingetTitle(wingetCommand.telemetryName),
      wingetCommand: wingetCommand,
      parent: this,
      persistentStorage: persistentStorage,
    );
    wingetTable.infos = await persistentStorage.loadAll();
    for (PackageInfosPeek info in wingetTable.infos) {
      info.setPublisher();
      info.setImplicitInfos();
    }
    wingetTable.status = DBStatus.ready;
    return wingetTable;
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
    log.info(
      'Amount of packages per Publisher',
      message: map.entries
          .sorted((a, b) => b.value.length.compareTo(a.value.length))
          .map((e) => '${e.key}: ${e.value.length}')
          .join(('\n')),
    );
  }

  static List<PackageInfosPeek> filterUpdates(List<PackageInfosPeek> infos) {
    List<PackageInfosPeek> toRemoveFromUpdates = [];
    for (PackageInfosPeek package in infos) {
      PackageId id = package.id!.value;
      if (PackageTables.instance.installed.idMap.containsKey(id)) {
        List<PackageInfosPeek> installedPackages =
            PackageTables.instance.installed.idMap[id]!;
        List<VersionOrString?> installedVersions =
            installedPackages.map((e) => e.version?.value).toList();
        if (installedVersions.any(
              (e) =>
                  e?.stringValue == package.availableVersion?.value.stringValue,
            ) ||
            installedVersions.any(
              (e) =>
                  e?.stringValue ==
                  "> ${package.availableVersion?.value.stringValue}",
            )) {
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
    return PackageTables.instance.installed.idMap.containsKey(
      package.id?.value,
    );
  }

  static bool isPackageUpgradable(PackageInfosPeek package) =>
      package.availableVersion != null &&
      package.availableVersion!.value.isVersion();

  static Future<bool> checkWingetAvailable() async {
    // TODO: make client agnostic; works currently only for CliClient
    ProcessResult result = await Process.run('where', ['winget']);
    return result.exitCode == 0;
  }

  void reloadDBs(WingetClient client) {
    for (WingetTable table in tables) {
      table.reloadFuture(client);
    }
  }

  void scheduleReloadDBs(WingetClient client) {
    Cron cron = Cron();
    cron.schedule(Schedule(hours: '*/1'), () {
      reloadDBs(client);
    });
  }
}
