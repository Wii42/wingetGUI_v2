import 'package:collection/collection.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/l10n/generated/app_localizations.dart';
import 'package:winget_gui/output_handling/one_line_info_parser.dart';
import 'package:winget_gui/output_handling/output_handler.dart';
import 'package:winget_gui/package_infos/package_infos_full.dart';
import 'package:winget_gui/winget_client/winget_client.dart';
import 'package:winget_gui/winget_client/winget_command.dart';
import 'package:winget_gui/winget_process/winget_process.dart';

import '../output_handling/parsed_output.dart';
import '../output_handling/show_parser.dart';
import '../package_sources/package_source.dart';
import '../winget_commands.dart';
import '../winget_process/winget_process_scheduler.dart';
import 'cli_winget_package_list_loader.dart';

class CliWingetClient extends WingetClient {
  CliWingetClient(this.wingetLocale);

  AppLocalizations wingetLocale;

  @override
  WingetTask<List<String>> about(CmdAbout cmd) {
    WingetProcess p = WingetProcess.fromWinget(Winget.about);
    return _getWingetTaskFromProcess(p);
  }

  @override
  WingetTask<PackageListWithHints> availablePackages(CmdAvailablePackages cmd) {
    return search(CmdSearch("", count: cmd.count, filter: cmd.filter));
  }

  @override
  WingetTask<List<String>> customCommand(CmdCustom cmd) {
    WingetProcess p = WingetProcess.fromCommand(cmd.arguments, name: cmd.name);
    return _getWingetTaskFromProcess(p);
  }

  @override
  WingetTask<List<String>> help(CmdHelp cmd) {
    WingetProcess p = WingetProcess.fromWinget(Winget.help);
    return _getWingetTaskFromProcess(p);
  }

  @override
  WingetTask<List<String>> installPackage(CmdInstall cmd) {
    WingetProcess p = WingetProcess.fromCommand([
      Winget.install.baseCommand,
      if (cmd.disableInteractivity) "--disable-interactivity",
      if (cmd.autoAcceptSourceAgreements) "--accept-source-agreements",
      if (cmd.autoAcceptPackageAgreements) "--accept-package-agreements",
      "--id",
      cmd.id,
      if (cmd.version != null) ...["-v", cmd.version!.stringValue],
    ], name: Winget.install.name);
    return _getWingetTaskFromProcess(p);
  }

  @override
  WingetTask<PackageListWithHints> installed(CmdInstalled cmd) {
    return _loadPackagesWithTableLoader(
      Winget.installed.fullCommand,
      filter: cmd.filter,
    );
  }

  @override
  WingetTask<PackageListWithHints> search(CmdSearch cmd) {
    List<String> command = [
      Winget.search.baseCommand,
      if (cmd.count != null) ...["--count", cmd.count.toString()],
      if (cmd.by != null)
        switch (cmd.by!) {
          SearchBy.id => "--id",
          SearchBy.name => "--name",
          SearchBy.moniker => "--moniker",
          SearchBy.tag => "--tag",
        },
      cmd.query,
    ];
    return _loadPackagesWithTableLoader(command, filter: cmd.filter);
  }

  @override
  WingetTask<List<String>> settings(CmdSettings cmd) {
    WingetProcess p = WingetProcess.fromWinget(Winget.settings);
    return _getWingetTaskFromProcess(p);
  }

  @override
  WingetTask<PackageInfosFull> showPackageDetails(CmdShow cmd) {
    Future<PackageInfosFull> result = _fetchPackageDetails(cmd);
    return WingetTask(
      result: result.asStream(),
      taskId: -1,
      hasCompletedSuccessfully: result.then(
        (_) => true,
        onError: (error, stacktrace) {
          print("$error\n$stacktrace");
          return false;
        },
      ),
    );
  }

  Future<PackageInfosFull> _fetchPackageDetails(CmdShow cmd) async {
    if (cmd.source != null) {
      PackageSource source = cmd.source!;
      try {
        PackageInfosFull infos = await source.fetchInfos(cmd.userLocale);
        return infos;
      } catch (e) {
        // Fallback to winget if the source fails
        print(
          "Failed to fetch package details from source ${source.manifestUrl}: $e\nFalling back to winget...",
        );
      }
    }
    WingetProcess p = WingetProcess.fromWinget(
      Winget.show,
      parameters: ['--id', cmd.id],
    );
    List<String> rawOutput = await p.outputStream.last;
    OutputHandler handler = OutputHandler(
      rawOutput,
      command: Winget.show.fullCommand,
    );
    handler.determineResponsibility(wingetLocale);
    List<ParsedOutput> parsedOutput = await handler.getParsedOutputList(
      wingetLocale,
    );
    Iterable<ParsedShow> shows = parsedOutput.whereType<ParsedShow>();
    return shows.firstOrNull?.infos ?? PackageInfosFull();
  }

  @override
  WingetTask<List<String>> uninstallPackage(CmdUninstall cmd) {
    List<String> command = [
      Winget.uninstall.baseCommand,
      '--id',
      cmd.id,
      if (cmd.version != null) ...['-v', cmd.version!.stringValue],
    ];
    WingetProcess p = WingetProcess.fromCommand(command);
    return _getWingetTaskFromProcess(p);
  }

  @override
  WingetTask<List<String>> updatePackage(CmdUpdate cmd) {
    List<String> command = [
      Winget.upgrade.baseCommand,
      '--id',
      cmd.id,
      if (cmd.disableInteractivity) "--disable-interactivity",
      if (cmd.autoAcceptSourceAgreements) "--accept-source-agreements",
      if (cmd.autoAcceptPackageAgreements) "--accept-package-agreements",
      if (cmd.includeUnknown) "--include-unknown",
    ];
    WingetProcess p = WingetProcess.fromCommand(command);
    return _getWingetTaskFromProcess(p);
  }

  @override
  WingetTask<PackageListWithHints> updates(CmdUpdates cmd) {
    List<String> command = [
      Winget.upgrade.baseCommand,
      if (cmd.includeUnknown) "--include-unknown",
    ];
    return _loadPackagesWithTableLoader(command, filter: cmd.filter);
  }

  WingetTask<List<String>> _getWingetTaskFromProcess(WingetProcess p) {
    return WingetTask(
      result: p.outputStream,
      taskId: p.process.id,
      hasCompletedSuccessfully: _hasProcessCompletedSuccessfully(p),
    );
  }

  Future<bool> _hasProcessCompletedSuccessfully(WingetProcess p) {
    return p.process.exitCode.then(
      (exitCode) => exitCode == 0,
      onError: (_) => false,
    );
  }

  WingetTask<PackageListWithHints> _loadPackagesWithTableLoader(
    List<String> command, {
    List<PackageInfosPeek> Function(List<PackageInfosPeek>)? filter,
  }) {
    WingetProcess p = WingetProcess.fromCommand(command);
    CliWingetPackageListLoader loader = CliWingetPackageListLoader(
      process: p,
    );
    Stream<PackageListWithHints> result = _packageListStream(filter, loader);
    return WingetTask(
      result: result,
      taskId: p.process.id,
      hasCompletedSuccessfully: _hasProcessCompletedSuccessfully(p),
    );
  }

  Stream<PackageListWithHints> _packageListStream(
    List<PackageInfosPeek> Function(List<PackageInfosPeek>)? filter,
    CliWingetPackageListLoader loader,
  ) async* {
    await loader.runWingetProcess(wingetLocale);
    List<PackageInfosPeek> infos = loader.extractInfos();
    if (filter != null) {
      infos = filter(infos);
    }
    if (filter != null) {
      infos = filter(infos);
    }
    List<OneLineInfo> hints = loader.extractHints();
    yield PackageListWithHints(infos, hints);
  }

  @override
  Stream<int> runningCommandsLength(CmdRunningCommands cmd) {
    return ProcessScheduler.instance.queueLengthStream;
  }

  @override
  Future<void> cancelTask(int taskId) {
    ProcessWrap? p = ProcessScheduler.instance.runningProcesses
        .firstWhereOrNull((a) => a.id == taskId);
    if (p != null) {
      ProcessScheduler.instance.removeProcess(p);
    }
    return Future.value();
  }
}
