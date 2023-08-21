import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String notFoundError = "NotFoundError";

enum Winget {
  updates(
      command: ['upgrade'],
      icon: FluentIcons.substitutions_in,
      route: '/updates'),
  installed(command: ['list'], icon: FluentIcons.library, route: '/installed'),
  about(command: ['--info'], icon: FluentIcons.info, route: '/about'),
  help(command: ['--help'], icon: FluentIcons.help, route: '/help'),
  search(
      command: ['search', "-n", '200'],
      icon: FluentIcons.search,
      route: '/search'),
  settings(
      command: ['settings'], icon: FluentIcons.settings, route: '/settings'),
  sources(
      command: ['source', 'list'],
      icon: FluentIcons.database_source,
      route: '/sources'),
  install(
      command: ['install'], icon: FluentIcons.installation, route: '/install'),
  upgrade(
      command: ['upgrade'],
      icon: FluentIcons.substitutions_in,
      route: '/upgrade'),
  uninstall(
      command: ['uninstall'], icon: FluentIcons.delete, route: '/uninstall'),
  show(command: ['show'], route: '/show');

  final List<String> command;
  final IconData? icon;
  final String route;

  const Winget({required this.command, this.icon, required this.route});

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
