import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/db/winget_table.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/widget_assets/package_peek_list_view.dart';
import 'package:winget_gui/widget_assets/winget_db_table_page.dart';
import 'package:winget_gui/winget_client/winget_client.dart';
import 'package:winget_gui/winget_commands.dart';

import '../winget_client/winget_command.dart';

class DeepSearchPage extends StatelessWidget {
  final CmdSearch searchCommand;
  final String? titleAddon;
  final bool Function(PackageInfosPeek)? packageFilter;

  const DeepSearchPage(
    this.searchCommand, {
    super.key,
    this.titleAddon,
    this.packageFilter,
  });

  @override
  Widget build(BuildContext context) {
    WingetClient client = context.watch<WingetClient>();
    WingetTable table = WingetTable(
      [],
      content: (locale) => locale.extendedSearch,
      wingetCommand: searchCommand,
    );
    table.reloadFuture(client);
    return WingetDBTablePage(
      title:
          (locale) =>
              titleAddon != null
                  ? Winget.search.titleWithInput(
                    titleAddon!,
                    localization: locale,
                  )
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
        "Route parameter of DeepSearchPage must not be null null",
      );
    }
    if (parameters.wingetCommand == null) {
      throw Exception(
        "Title addon of route parameter of DeepSearchPage must not be null",
      );
    }
    if (parameters.wingetCommand! is CmdSearch) {
      throw Exception(
        "Route parameter of DeepSearchPage must be of type CmdSearch",
      );
    }
    CmdSearch searchFor = parameters.wingetCommand! as CmdSearch;
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
