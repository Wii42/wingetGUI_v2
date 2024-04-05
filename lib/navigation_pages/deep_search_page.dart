import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/output_handler.dart';
import 'package:winget_gui/widget_assets/package_peek_list_view.dart';
import 'package:winget_gui/widget_assets/winget_db_table_page.dart';

import '../helpers/route_parameter.dart';
import '../output_handling/package_infos/package_infos_peek.dart';
import '../winget_commands.dart';
import '../winget_db/db_table.dart';

class DeepSearchPage extends StatelessWidget {
  final List<String> searchFor;
  final String? titleAddon;
  final bool Function(PackageInfosPeek)? packageFilter;
  const DeepSearchPage(this.searchFor,
      {super.key, this.titleAddon, this.packageFilter});

  @override
  Widget build(BuildContext context) {
    AppLocalizations wingetLocale = OutputHandler.getWingetLocale(context);
    WingetTable table = WingetTable(
      [],
      content: (locale) => locale.extendedSearch,
      wingetCommand: [Winget.search.baseCommand, ...searchFor],
    );
    table.reloadFuture(wingetLocale);
    return WingetDBTablePage(
      title: (locale) => titleAddon != null
          ? Winget.search.titleWithInput(titleAddon!, localization: locale)
          : Winget.search.title(locale),
      dbTable: table,
      menuOptions: const PackageListMenuOptions(
        onlyWithSourceButton: false,
        filterField: false,
      ),
      packageOptions: const PackageListPackageOptions(showMatch: true),
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
