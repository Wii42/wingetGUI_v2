import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/route_parameter.dart';

import 'winget_process/output_page_starter.dart';

const String notFoundError = "NotFoundError";

enum Winget {
  updates(command: ['upgrade', '--include-unknown']),
  installed(command: ['list']),
  about(command: ['--info']),
  help(command: ['--help']),
  search(command: ['search', "-n", '200']),
  settings(command: ['settings']),
  sources(command: ['source', 'list']),
  install(command: [
    'install',
    '--disable-interactivity',
    '--accept-source-agreements',
    '--accept-package-agreements'
  ]),
  upgrade(command: ['upgrade']),
  upgradeAll(command: ['upgrade', '--all']),
  uninstall(command: ['uninstall']),
  show(command: ['show']);

  final List<String> command;

  const Winget({required this.command});

  String title(AppLocalizations local) {
    String title = local.wingetTitle(name);
    if (title == notFoundError) {
      throw Exception("$title: $name in Winget.title");
    }
    return title;
  }

  String titleWithInput(String input,
      {required AppLocalizations localization}) {
    String titlePrefix = localization.wingetTitlePrefix(name);
    String prefix;
    if (titlePrefix != notFoundError) {
      prefix = titlePrefix;
    } else {
      prefix = title(localization);
    }
    return "$prefix $input".trim();
  }

  Widget processPage(RouteParameter? parameters) {
    return OutputPageStarter(
      command: [...command, ...?parameters?.commandParameter],
      winget: this,
      titleInput: parameters?.titleAddon,
    );
  }
}
