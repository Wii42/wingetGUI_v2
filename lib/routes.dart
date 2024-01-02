import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/main.dart';
import 'package:winget_gui/navigation_pages/advanced_options_page.dart';
import 'package:winget_gui/navigation_pages/command_prompt_page.dart';
import 'package:winget_gui/navigation_pages/search_page.dart';
import 'package:winget_gui/navigation_pages/settings_page.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';
import 'package:winget_gui/output_handling/table/apps_table/package_peek.dart';
import 'package:winget_gui/widget_assets/package_details_from_web.dart';
import 'package:winget_gui/widget_assets/package_peek_list_view.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';
import 'package:winget_gui/winget_commands.dart';

import 'helpers/route_parameter.dart';
import 'navigation_pages/publisher_page.dart';

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
  show(route: 'show', body: packageDetailsPage),
  upgradeAll(route: '/upgradeAll', winget: Winget.upgradeAll),

  searchPage(
      icon: FluentIcons.search, route: '/searchPage', body: SearchPage.inRoute),
  commandPromptPage(
      icon: FluentIcons.command_prompt,
      route: '/commandPromptPage',
      body: CommandPromptPage.inRoute),
  advancedOptions(
      icon: FluentIcons.lightning_bolt,
      route: '/advancedOptions',
      body: AdvancedOptionsPage.inRoute),
  settingsPage(
      icon: FluentIcons.settings,
      route: '/settingsPage',
      body: SettingsPage.inRoute),
  updatesPage(
      icon: FluentIcons.substitutions_in,
      route: '/updatesPage',
      body: UpdatesPage.inRoute),
  installedPage(
      icon: FluentIcons.library,
      route: '/installedPage',
      body: InstalledPage.inRoute),
  publisherPage(
      route: '/publisherPage',
      body: PublisherPage.inRoute),
  ;

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
      throw Exception("$title: $name in Routes.title");
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

  static Widget packageDetailsPage(RouteParameter? parameters) {
    if (parameters is PackageRouteParameter) {
      PackageInfosPeek package = parameters.package;
      if (package.isWinget()) {
        if (package.versionManifestPath != null) {
          return PackageDetailsFromWeb(
              package: package, titleInput: parameters.titleAddon);
        }
      }
    }
    return Winget.show.processPage(parameters);
  }
}

class InstalledPage extends StatelessWidget{
  const InstalledPage({super.key});

  static Widget inRoute([dynamic parameters]) {
    return const InstalledPage();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return PaneItemBody(
      title: Winget.installed.title(locale),
      child: PackagePeekListView(
          dbTable: wingetDB.installed,
          isInstalled: (_, __) => true,
          isUpgradable: (package, __) => package.hasAvailableVersion()),
    );
  }
}

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  static Widget inRoute([dynamic parameters]) {
    return const UpdatesPage();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return PaneItemBody(
      title: Winget.updates.title(locale),
      child: PackagePeekListView(
          dbTable: wingetDB.updates,
          isInstalled: (_, __) => true,
          isUpgradable: (_, __) => true),
    );
  }
}
