import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String notFoundError = "NotFoundError";

enum Winget {
  updates(
    command: ['upgrade'],
    icon: FluentIcons.substitutions_in,
  ),
  installed(command: ['list'], icon: FluentIcons.library),
  about(command: ['--info'], icon: FluentIcons.info),
  help(command: ['--help'], icon: FluentIcons.help),
  search(
    command: ['search', "-n", '200'],
    icon: FluentIcons.search,
  ),
  settings(command: ['settings'], icon: FluentIcons.settings),
  sources(command: ['source', 'list'], icon: FluentIcons.database_source),
  install(command: ['install'], icon: FluentIcons.installation),
  upgrade(command: ['upgrade'], icon: FluentIcons.substitutions_in),
  uninstall(command: ['uninstall'], icon: FluentIcons.delete),
  ;

  final List<String> command;
  final IconData? icon;

  const Winget({required this.command, this.icon});

  String title(AppLocalizations local) {
    String title = local.wingetTitle(name);
    if (title == notFoundError) {
      throw Exception(title);
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
    return "$prefix '$input'";
  }
}
