import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/db/winget_table_loader.dart';
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

class CliWingetClient extends WingetClient {
  CliWingetClient(this.wingetLocale);

  AppLocalizations wingetLocale;

  @override
  Future<List<String>> about(CmdAbout cmd) async {
    WingetProcess p = WingetProcess.fromWinget(Winget.about);
    return p.outputStream.last;
  }

  @override
  Stream<PackageListWithHints> availablePackages(CmdAvailablePackages cmd) {
    return search(CmdSearch("", count: cmd.count));
  }

  @override
  Stream<List<String>> customCommand(CmdCustom cmd) {
    WingetProcess p = WingetProcess.fromCommand(cmd.arguments, name: cmd.name);
    return p.outputStream;
  }

  @override
  Future<List<String>> help(CmdHelp cmd) {
    WingetProcess p = WingetProcess.fromWinget(Winget.help);
    return p.outputStream.last;
  }

  @override
  Stream<List<String>> installPackage(CmdInstall cmd) {
    WingetProcess p = WingetProcess.fromCommand([
      Winget.install.baseCommand,
      if (cmd.disableInteractivity) "--disable-interactivity",
      if (cmd.autoAcceptSourceAgreements) "--accept-source-agreements",
      if (cmd.autoAcceptPackageAgreements) "--accept-package-agreements",
      "--id",
      cmd.id,
      if (cmd.version != null) ...["-v", cmd.version!.stringValue],
    ], name: Winget.install.name);
    return p.outputStream;
  }

  @override
  Stream<PackageListWithHints> installed(CmdInstalled cmd) {
    return _loadPackagesWithTableLoader(Winget.installed.fullCommand);
  }

  @override
  Stream<PackageListWithHints> search(CmdSearch cmd) {
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
    return _loadPackagesWithTableLoader(command);
  }

  @override
  Future<List<String>> settings(CmdSettings cmd) {
    WingetProcess p = WingetProcess.fromWinget(Winget.settings);
    return p.outputStream.last;
  }

  @override
  Future<PackageInfosFull> showPackageDetails(CmdShow cmd) async {
    if (cmd.source != null) {
      PackageSource source = cmd.source!;
      try {
        return source.fetchInfos(cmd.userLocale);
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
  Stream<List<String>> uninstallPackage(CmdUninstall cmd) {
    List<String> command = [
      Winget.uninstall.baseCommand,
      '--id',
      cmd.id,
      if (cmd.version != null) ...['-v', cmd.version!.stringValue],
    ];
    WingetProcess p = WingetProcess.fromCommand(command);
    return p.outputStream;
  }

  @override
  Stream<List<String>> updatePackage(CmdUpdate cmd) {
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
    return p.outputStream;
  }

  @override
  Stream<PackageListWithHints> updates(CmdUpdates cmd) {
    List<String> command = [
      Winget.upgrade.baseCommand,
      if (cmd.includeUnknown) "--include-unknown",
    ];
    return _loadPackagesWithTableLoader(command);
  }

  Stream<PackageListWithHints> _loadPackagesWithTableLoader(
    List<String> command,
  ) async* {
    WingetTableLoader loader = WingetTableLoader(command: command);
    await loader.init(wingetLocale).drain();
    List<PackageInfosPeek> infos = loader.extractInfos();
    List<OneLineInfo> hints = loader.extractHints();
    yield PackageListWithHints(infos, hints);
  }
}
