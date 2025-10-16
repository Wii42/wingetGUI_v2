import 'dart:convert';

import 'package:async/async.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/helpers/extensions/stream_modifier.dart';
import 'package:winget_gui/package_infos/package_infos_full.dart';
import 'package:winget_gui/package_infos/parsers/powershell_peek_parser.dart';
import 'package:winget_gui/package_infos/peek_to_full_extension.dart';
import 'package:winget_gui/winget_client/cli_winget/cli_winget_client.dart';
import 'package:winget_gui/winget_client/cli_winget/process_scheduler_mixin.dart';
import 'package:winget_gui/winget_client/winget_client.dart';
import 'package:winget_gui/winget_client/winget_command.dart';

import '../../package_sources/package_source.dart';
import '../../winget_process/winget_process_scheduler.dart';

class PowershellWingetClient extends WingetClient with ProcessSchedulerMixin {
  @override
  WingetTask<List<String>> about(CmdAbout cmd) {
    return _runCommand(
      command: ["Get-WinGetVersion"],
      cmd: cmd,
      parseData: (data) => data.rememberingStream(),
      retry: () => about(cmd),
    );
  }

  @override
  WingetTask<PackageListWithHints> availablePackages(CmdAvailablePackages cmd) {
    return search(CmdSearch("", count: cmd.count, filter: cmd.filter));
  }

  @override
  WingetTask<List<String>> customCommand(CmdCustom cmd) {
    return _runCommand(
      command: cmd.arguments,
      cmd: cmd,
      parseData: (data) => data.rememberingStream(),
      retry: () => customCommand(cmd),
    );
  }

  @override
  WingetTask<List<String>> help(CmdHelp cmd) {
    return _runCommand(
      command: ["(Get-Module microsoft.winget.client).ExportedCommands"],
      cmd: cmd,
      parseData: (data) => data.rememberingStream(),
      retry: () => help(cmd),
    );
  }

  @override
  WingetTask<List<String>> installPackage(CmdInstall cmd) {
    return _runCommand(
      command: [
        "Install-WinGetPackage",
        if (cmd.disableInteractivity) "-Mode Silent",
        "-Id",
        cmd.id,
        if (cmd.version != null) ...["-Version", cmd.version!.stringValue],
      ],
      cmd: cmd,
      parseData: (data) => data.rememberingStream(),
      retry: () => installPackage(cmd),
    );
  }

  @override
  WingetTask<PackageListWithHints> installed(CmdInstalled cmd) {
    return _runCommand(
      command: ["Get-WingetPackage"],
      forEachToJson: true,
      cmd: cmd,
      parseData: (data) => outputToPackageListWithHints(data, cmd.filter),
      retry: () => installed(cmd),
    );
  }

  @override
  WingetTask<PackageListWithHints> search(CmdSearch cmd) {
    List<String> command = [
      "Find-WinGetPackage",
      if (cmd.count != null) ...["-Count", cmd.count.toString()],
      if (cmd.by != null)
        switch (cmd.by!) {
          SearchBy.id => "-Id",
          SearchBy.name => "-Name",
          SearchBy.moniker => "-Moniker",
          SearchBy.tag => "-Tag",
        },
      cmd.query,
    ];
    return _runCommand(
      command: command,
      forEachToJson: true,
      cmd: cmd,
      parseData: (data) => outputToPackageListWithHints(data, cmd.filter),
      retry: () => search(cmd),
    );
  }

  @override
  WingetTask<List<String>> settings(CmdSettings cmd) {
    return _runCommand(
      command: ["Get-WinGetUserSetting"],
      cmd: cmd,
      parseData: (data) => data.rememberingStream(),
      retry: () => settings(cmd),
    );
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
          print("$error\n$stacktrace");
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
        print(
          "Failed to fetch package details from source ${source.manifestUrl}: $e\nFalling back to winget...",
        );
      }
    } else {
      yield PackageInfosFull();
    }
  }

  @override
  WingetTask<List<String>> uninstallPackage(CmdUninstall cmd) {
    return _runCommand(
      command: [
        "Uninstall-WinGetPackage",
        "-Id",
        cmd.id,
        if (cmd.version != null) ...["-Version", cmd.version!.stringValue],
      ],
      cmd: cmd,
      parseData: (data) => data.rememberingStream(),
      retry: () => uninstallPackage(cmd),
    );
  }

  @override
  WingetTask<List<String>> updatePackage(CmdUpdate cmd) {
    return _runCommand(
      command: [
        "Install-WinGetPackage",
        if (cmd.disableInteractivity) "-Mode Silent",
        "-Id",
        cmd.id,
      ],
      cmd: cmd,
      parseData: (data) => data.rememberingStream(),
      retry: () => updatePackage(cmd),
    );
  }

  @override
  WingetTask<PackageListWithHints> updates(CmdUpdates cmd) {
    return _runCommand(
      command: ["Get-WingetPackage", "|", "Where-Object IsUpdateAvailable"],
      forEachToJson: true,
      cmd: cmd,
      parseData: (data) => outputToPackageListWithHints(data, cmd.filter),
      retry: () => updates(cmd),
    );
  }

  Stream<PackageListWithHints> outputToPackageListWithHints(
    Stream<String> data,
    List<PackageInfosPeek> Function(List<PackageInfosPeek>)? filter,
  ) async* {
    final List<PackageInfosPeek> packages = [];
    String lastLine = "";
    try {
      await for (String chunk in data) {
        chunk = lastLine + chunk;
        List<String> lines = chunk.split('\n');
        lastLine = lines.removeLast();
        for (String line in lines) {
          line = line.trim();
          if (line.isEmpty) continue;
          yield parsePackage(line, packages, filter);
        }
      }
      lastLine = lastLine.trim();
      if (lastLine.isNotEmpty) {
        yield parsePackage(lastLine, packages, filter);
      }
    } finally {
      // On error or if no data was received, still yield what we have
      yield PackageListWithHints(
        filter != null ? filter(packages) : packages,
        [],
      );
    }
  }

  PackageListWithHints parsePackage(
    String line,
    List<PackageInfosPeek> packages,
    List<PackageInfosPeek> Function(List<PackageInfosPeek>)? filter,
  ) {
    Map<String, dynamic> map = jsonDecode(line);
    PowershellPeekParser parser = PowershellPeekParser(map);
    PackageInfosPeek package = parser.parse();
    packages.add(package);
    return PackageListWithHints(
      filter != null ? filter(packages) : packages,
      [],
    );
  }

  static const String _forEachToJson =
      "| ForEach-Object { \$_ | ConvertTo-Json -Compress }";

  WingetTask<T> _runCommand<T extends Object>({
    required List<String> command,
    bool forEachToJson = false,
    required WingetCommand cmd,
    required Stream<T> Function(Stream<String>) parseData,
    required WingetTask<T> Function() retry,
  }) {
    ProcessWrap p = ProcessWrap.powershell([
      ...command,
      if (forEachToJson) _forEachToJson,
    ], forceUtf8: true);
    Stream<String> data = p.stdout.transform(
      Utf8Codec(allowMalformed: true).decoder,
    );
    return WingetTask(
      result: parseData(data),
      taskId: p.id,
      hasCompletedSuccessfully: CliWingetClient.hasProcessCompletedSuccessfully(
        p,
      ),
      cmd: cmd,
      retry: retry,
    );
  }
}
