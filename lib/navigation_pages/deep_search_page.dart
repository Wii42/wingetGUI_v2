import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/output_handler.dart';
import 'package:winget_gui/widget_assets/package_peek_list_view.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';
import 'package:winget_gui/winget_db/db_table_creator.dart';

import '../helpers/route_parameter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../output_handling/package_infos/package_infos_peek.dart';
import '../winget_commands.dart';

class DeepSearchPage extends StatelessWidget {
  final List<String> searchFor;
  final String? titleAddon;
  final bool Function(PackageInfosPeek)? packageFilter;
  const DeepSearchPage(this.searchFor,
      {super.key, this.titleAddon, this.packageFilter});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return PaneItemBody(
        title: titleAddon != null
            ? Winget.search.titleWithInput(titleAddon!, localization: locale)
            : Winget.search.title(locale),
        child: buildContent(context));
  }

  Widget buildContent(BuildContext context) {
    AppLocalizations wingetLocale = OutputHandler.getWingetLocale(context);
    DBTableCreator creator = DBTableCreator(
        content: 'deep search',
        command: [Winget.search.baseCommand, ...searchFor]);
    return StreamBuilder<String>(
      stream: creator.init(wingetLocale),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return PackagePeekListView(
            dbTable: creator.returnTable(),
            menuOptions: const PackageListMenuOptions(
              onlyWithSourceButton: false,
              filterField: false,
            ),
            packageOptions: const PackageListPackageOptions(showMatch: true),
          );
        }
        if (snapshot.hasData) {
          return Center(child: Text(snapshot.data!));
        } else {
          return const Center(child: Text('Loading...'));
        }
      },
    );
  }

  static Widget inRoute(RouteParameter? parameters) {
    if (parameters == null) {
      throw Exception(
          "Route parameter of DeepSearchPage must not be null null");
    }
    if (parameters.commandParameter == null) {
      throw Exception(
          "Title addon of route parameter of DeepSearchPage must not be null");
    }
    List<String> searchFor = parameters.commandParameter!;
    bool Function(PackageInfosPeek)? packageFilter;
    if (parameters is SearchRouteParameter) {
      packageFilter = parameters.packageFilter;
    }
    return DeepSearchPage(
      searchFor,
      titleAddon: parameters.titleAddon,
      packageFilter: packageFilter,
    );
  }
}
