import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/command_prompt_page.dart';
import 'package:winget_gui/search_page.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'helpers/route_parameter.dart';

enum Routes {
  updates(
      icon: FluentIcons.substitutions_in,
      route: '/updates',
      winget: Winget.updates),
  installed(
      icon: FluentIcons.library, route: '/installed', winget: Winget.installed),
  about(icon: FluentIcons.info, route: '/about', winget: Winget.about),
  help(icon: FluentIcons.help, route: '/help', winget: Winget.help),
  search(icon: FluentIcons.search, route: '/search', winget: Winget.search),
  settings(
      icon: FluentIcons.settings, route: '/settings', winget: Winget.settings),
  sources(
      icon: FluentIcons.database_source,
      route: '/sources',
      winget: Winget.sources),
  install(
      icon: FluentIcons.installation,
      route: '/install',
      winget: Winget.install),
  upgrade(
      icon: FluentIcons.substitutions_in,
      route: '/upgrade',
      winget: Winget.upgrade),
  uninstall(
      icon: FluentIcons.delete, route: '/uninstall', winget: Winget.uninstall),
  show(route: '/show', winget: Winget.show),
  upgradeAll(route: '/upgradeAll', winget: Winget.upgradeAll),

  searchPage(
      icon: FluentIcons.search, route: '/searchPage', body: SearchPage.inRoute),
  commandPromptPage(
      icon: FluentIcons.command_prompt,
      route: '/commandPromptPage',
      body: CommandPromptPage.inRoute);

  final String route;
  final IconData? icon;
  final Winget? winget;
  final Widget Function(RouteParameter? parameters)? body;

  const Routes({required this.route, this.body, this.winget, this.icon});

  Widget buildPage([dynamic parameters]) {
    assert(winget != null || body != null);
    if (body != null) return body!(parameters);
    return winget!.processPage(parameters);
  }

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
    return "$prefix $input";
  }
}
