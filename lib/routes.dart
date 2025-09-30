import 'package:fluent_ui/fluent_ui.dart';
import 'package:persistent_storage_interface/interface.dart';
import 'package:persistent_storage_interface/service.dart';
import 'package:provider/provider.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/l10n/generated/app_localizations.dart';
import 'package:winget_gui/navigation_pages/advanced_options_page.dart';
import 'package:winget_gui/navigation_pages/command_prompt_page.dart';
import 'package:winget_gui/navigation_pages/deep_search_page.dart';
import 'package:winget_gui/navigation_pages/installed_page.dart';
import 'package:winget_gui/navigation_pages/logs_page.dart';
import 'package:winget_gui/navigation_pages/publisher_page.dart';
import 'package:winget_gui/navigation_pages/search_page.dart';
import 'package:winget_gui/navigation_pages/settings_page.dart';
import 'package:winget_gui/navigation_pages/updates_page.dart';
import 'package:winget_gui/widget_assets/package_peek.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';
import 'package:winget_gui/winget_client/winget_client.dart';
import 'package:winget_gui/winget_client/winget_command.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:winget_gui/winget_process/result_page.dart';

import 'db/package_tables.dart';
import 'navigation_pages/db_table_page.dart';

enum Routes {
  about(
    icon: FluentIcons.info,
    route: '/about',
    winget: Winget.about,
    body: aboutPage,
  ),
  help(
    icon: FluentIcons.help,
    route: '/help',
    winget: Winget.help,
    body: helpPage,
  ),
  sources(
    icon: FluentIcons.database_source,
    route: '/sources',
    winget: Winget.sources,
    body: aboutPage,
  ),
  show(route: 'show', body: packageDetailsPage),
  searchPage(
    icon: FluentIcons.search,
    route: '/searchPage',
    body: SearchPage.inRoute,
  ),
  commandPromptPage(
    icon: FluentIcons.command_prompt,
    route: '/commandPromptPage',
    body: CommandPromptPage.inRoute,
  ),
  advancedOptions(
    icon: FluentIcons.lightning_bolt,
    route: '/advancedOptions',
    body: AdvancedOptionsPage.inRoute,
  ),
  settingsPage(
    icon: FluentIcons.settings,
    route: '/settingsPage',
    body: SettingsPage.inRoute,
  ),
  updatesPage(
    icon: FluentIcons.substitutions_in,
    route: '/updatesPage',
    body: UpdatesPage.inRoute,
  ),
  installedPage(
    icon: FluentIcons.library,
    route: '/installedPage',
    body: InstalledPage.inRoute,
  ),
  publisherPage(route: '/publisherPage', body: PublisherPage.inRoute),
  deepSearchPage(route: '/deepSearchPage', body: DeepSearchPage.inRoute),
  logsPage(
    icon: FluentIcons.text_document,
    route: '/logPage',
    body: LogsPage.inRoute,
  ),
  logDetailsPage(route: '/logDetailsPage', body: LogDetailsPage.inRoute),
  dbTablePage(route: '/dbTablePage', body: DBTableWidget.inRoute),
  tinkeringSection(
    route: '/tinkeringSection',
    body: TinkeringSection.inRoute,
    icon: FluentIcons.rocket,
  );

  final String route;
  final IconData? icon;
  final Winget? winget;
  final Widget Function(RouteParameter? parameters) body;

  const Routes({
    required this.route,
    required this.body,
    this.winget,
    this.icon,
  });

  Widget buildPage([dynamic parameters]) {
    return body(parameters);
  }

  String title(AppLocalizations local) {
    String title = local.wingetTitle(name);
    if (title == notFoundError) {
      throw Exception("$title: $name in Routes.title");
    }
    return title;
  }

  String titleWithInput(
    String input, {
    required AppLocalizations localization,
  }) {
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
    if (parameters is! PackageRouteParameter) {
      throw Exception('Parameters must be PackageRouteParameter');
    }
    if (parameters.wingetCommand is! CmdShow) {
      throw Exception('wingetCommand must be CmdShow');
    }
    CmdShow cmd = parameters.wingetCommand! as CmdShow;
    return Builder(
      builder: (context) {
        WingetClient client = context.read<WingetClient>();
        return PackageInfosFullPage(
          task: client.showPackageDetails(cmd),
          titleInput: parameters.titleAddon,
        );
      },
    );
  }

  static Widget aboutPage(RouteParameter? _) {
    return Builder(
      builder: (context) {
        WingetClient client = context.read<WingetClient>();
        return TextResultPage(task: client.about(CmdAbout()));
      },
    );
  }

  static Widget helpPage(RouteParameter? _) {
    return Builder(
      builder: (context) {
        WingetClient client = context.read<WingetClient>();
        return TextResultPage(task: client.help(CmdHelp()));
      },
    );
  }
}

class TinkeringSection extends StatelessWidget {
  const TinkeringSection({super.key});

  static Widget inRoute([RouteParameter? parameters]) {
    return const TinkeringSection();
  }

  @override
  Widget build(BuildContext context) {
    WingetClient client = context.watch<WingetClient>();
    return PaneItemBody(
      title: Routes.tinkeringSection.title(AppLocalizations.of(context)!),
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          buildDBSettings(client),
          SettingsPage.settingsItem(
            'View DB Tables',
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                dbButton(context, PersistentStorageService.instance.favicon),
                dbButton(
                  context,
                  PersistentStorageService.instance.publisherNameByPackageId,
                ),
                dbButton(
                  context,
                  PersistentStorageService.instance.publisherNameByPublisherId,
                ),
              ].withSpaceBetween(height: 10),
            ),
          ),
          SettingsPage.settingsItem(
            "Tasks",
            Button(
              onPressed: () => client.cancelAllTasks(),
              child: Text("Cancel all tasks"),
            ),
          ),
          PackagePeek.prototypeWidget,
        ].withSpaceBetween(height: 10),
      ),
    );
  }

  Widget buildDBSettings(WingetClient client) {
    return SettingsPage.settingsItem(
      'WingetDB',
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Button(
            onPressed: () async {
              PackageTables.instance.updates.reloadFuture(client);
            },
            child: const Text('Reload updates'),
          ),
          Button(
            onPressed: () {
              PackageTables.instance.updates.removeAllInfos();
            },
            child: const Text('Remove all updates'),
          ),
        ].withSpaceBetween(height: 20),
      ),
    );
  }

  Button dbButton(BuildContext context, TableRepresentation table) {
    return Button(
      child: Text(table.tableName),
      onPressed:
          () => Navigator.of(context).pushNamed(
            Routes.dbTablePage.route,
            arguments: DBRouteParameter(dbTable: table),
          ),
    );
  }
}
