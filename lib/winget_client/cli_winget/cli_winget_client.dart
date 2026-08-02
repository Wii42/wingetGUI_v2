import 'dart:developer';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/l10n/generated/app_localizations.dart';
import 'package:winget_gui/output_handling/one_line_info_parser.dart';
import 'package:winget_gui/output_handling/output_handler.dart';
import 'package:winget_gui/package_infos/package_infos_full.dart';
import 'package:winget_gui/package_infos/peek_to_full_extension.dart';
import 'package:winget_gui/winget_client/cli_winget/process_scheduler_mixin.dart';
import 'package:winget_gui/winget_client/winget_client.dart';
import 'package:winget_gui/winget_client/winget_command.dart';
import 'package:winget_gui/winget_process/winget_process.dart';

import '../../output_handling/parsed_output.dart';
import '../../output_handling/show_parser.dart';
import '../../package_sources/package_source.dart';
import '../../winget_commands.dart';
import '../../winget_process/winget_process_scheduler.dart';
import 'cli_winget_package_list_loader.dart';

class CliWingetClient extends WingetClient with ProcessSchedulerMixin {
  CliWingetClient(this.wingetLocale);

  AppLocalizations wingetLocale;

  @override
  WingetTask<List<String>> about(CmdAbout cmd) {
    WingetProcess p = WingetProcess.fromWinget(Winget.about);
    return _getWingetTaskFromProcess(p, cmd, () => about(cmd));
  }

  @override
  WingetTask<PackageListWithHints> availablePackages(CmdAvailablePackages cmd) {
    return search(CmdSearch("", count: cmd.count, filter: cmd.filter));
  }

  @override
  WingetTask<List<String>> customCommand(CmdCustom cmd) {
    WingetProcess p = WingetProcess.fromCommand(cmd.arguments, name: cmd.name);
    return _getWingetTaskFromProcess(p, cmd, () => customCommand(cmd));
  }

  @override
  WingetTask<List<String>> help(CmdHelp cmd) {
    WingetProcess p = WingetProcess.fromWinget(Winget.help);
    return _getWingetTaskFromProcess(p, cmd, () => help(cmd));
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
    return _getWingetTaskFromProcess(p, cmd, () => installPackage(cmd));
  }

  @override
  WingetTask<PackageListWithHints> installed(CmdInstalled cmd) {
    return _loadPackagesWithTableLoader(
      Winget.installed.fullCommand,
      cmd,
      () => installed(cmd),
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
    return _loadPackagesWithTableLoader(
      command,
      cmd,
      () => search(cmd),
      filter: cmd.filter,
    );
  }

  @override
  WingetTask<List<String>> settings(CmdSettings cmd) {
    WingetProcess p = WingetProcess.fromWinget(Winget.settings);
    return _getWingetTaskFromProcess(p, cmd, () => settings(cmd));
  }

  @override
  WingetTask<PackageInfosFull> showPackageDetails(CmdShow cmd) {
    Stream<PackageInfosFull> result = _fetchPackageDetails(cmd);

    final StreamSplitter<PackageInfosFull> splitter = StreamSplitter(result);

    final Stream<PackageInfosFull> forwarded =
        splitter.split(); // für normale Konsumenten
    final Future<PackageInfosFull> lastFuture =
        splitter.split().last; // separater Ast nur für .last

    splitter.close();
    return WingetTask(
      result: forwarded,
      taskId: -1,
      hasCompletedSuccessfully: lastFuture.then(
        (_) => true,
        onError: (error, stacktrace) {
          log(
            "$error\n$stacktrace",
            name: "CliWingetClient.showPackageDetails",
            error: error,
            stackTrace: stacktrace,
          );
          return false;
        },
      ),
      cmd: cmd,
      retry: () => showPackageDetails(cmd),
    );
  }

  Stream<PackageInfosFull> _fetchPackageDetails(CmdShow cmd) async* {
    if (cmd.source != null) {
      PackageSource source = cmd.source!;
      yield source.package.toPeek().toFull();
      try {
        Stream<PackageInfosFull> infos = source.fetchInfos(cmd.userLocale);
        yield* infos;
        return;
      } catch (e) {
        // Fallback to winget if the source fails
        log(
          "Failed to fetch package details from source ${source.manifestUrl}: $e\nFalling back to winget...",
          name: "CliWingetClient._fetchPackageDetails",
          error: e,
        );
      }
    }
    yield* _fetchInfosLocally(cmd);
  }

  Stream<PackageInfosFull> _fetchInfosLocally(CmdShow cmd) async* {
    WingetProcess p = WingetProcess.fromWinget(
      Winget.show,
      parameters: ['--id', cmd.id],
    );
    Stream<List<String>> rawOutput = p.outputStream;
    await for (List<String> event in rawOutput) {
      OutputHandler handler = OutputHandler(event, command: p.command);
      handler.determineResponsibility(wingetLocale);
      List<ParsedOutput> parsedOutput = await handler.getParsedOutputList(
        wingetLocale,
      );
      Iterable<ParsedShow> shows = parsedOutput.whereType<ParsedShow>();
      yield shows.firstOrNull?.infos ?? PackageInfosFull();
    }
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
    return _getWingetTaskFromProcess(p, cmd, () => uninstallPackage(cmd));
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
    return _getWingetTaskFromProcess(p, cmd, () => updatePackage(cmd));
  }

  @override
  WingetTask<PackageListWithHints> updates(CmdUpdates cmd) {
    List<String> command = [
      Winget.upgrade.baseCommand,
      if (cmd.includeUnknown) "--include-unknown",
    ];
    return _loadPackagesWithTableLoader(
      command,
      cmd,
      () => updates(cmd),
      filter: cmd.filter,
    );
  }

  WingetTask<List<String>> _getWingetTaskFromProcess(
    WingetProcess p,
    WingetCommand cmd,
    WingetTask<List<String>> Function() retry,
  ) {
    return WingetTask(
      result: p.outputStream,
      taskId: p.process.id,
      hasCompletedSuccessfully: hasProcessCompletedSuccessfully(p.process),
      cmd: cmd,
      retry: retry,
    );
  }

  static Future<bool> hasProcessCompletedSuccessfully(ProcessWrap p) {
    return p.exitCode.then((exitCode) => exitCode == 0, onError: (_) => false);
  }

  WingetTask<PackageListWithHints> _loadPackagesWithTableLoader(
    List<String> command,
    WingetCommand cmd,
    WingetTask<PackageListWithHints> Function() retry, {
    List<PackageInfosPeek> Function(List<PackageInfosPeek>)? filter,
  }) {
    WingetProcess p = WingetProcess.fromCommand(command);
    CliWingetPackageListLoader loader = CliWingetPackageListLoader(process: p);
    Stream<PackageListWithHints> result = _packageListStream(filter, loader);
    return WingetTask(
      result: result,
      taskId: p.process.id,
      hasCompletedSuccessfully: hasProcessCompletedSuccessfully(p.process),
      cmd: cmd,
      retry: retry,
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
}
