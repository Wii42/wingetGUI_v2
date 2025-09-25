import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/l10n/generated/app_localizations.dart';
import 'package:winget_gui/widget_assets/buttons/tooltips.dart';
import 'package:winget_gui/winget_client/winget_client.dart';

import '../winget_client/winget_command.dart';

class WingetTableLoader {
  late final Logger log;
  static final Logger staticLog = Logger(null, sourceType: WingetTableLoader);

  WingetPackageListCommand wingetCommand;

  Stream<PackageListWithHints>? packages;

  LocalizedString content;

  WingetTableLoader(this.wingetCommand, {this.content = defaultContent}) {
    log = Logger(this);
  }

  static String defaultContent(AppLocalizations locale) => locale.output;

  Stream<LocalizedString> init(WingetClient client) async* {
    yield (locale) =>
        locale.readOutputOfCommand("winget: ${wingetCommand.telemetryName}");
    packages = client.executePackageListCommand(wingetCommand).result;

    yield (locale) => locale.parsingContent(content(locale));
    return;
  }
}
