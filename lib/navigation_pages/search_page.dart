import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/routes.dart';
import 'package:winget_gui/widget_assets/package_peek_list_view.dart';
import 'package:winget_gui/widget_assets/winget_db_table_page.dart';

import '../widget_assets/sort_by.dart';
import '../winget_db/db_table.dart';
import '../winget_db/winget_db.dart';

class SearchPage extends StatelessWidget {
  SearchPage({super.key});

  final TextEditingController controller = TextEditingController();
  final DBTable dbTable = WingetDB.instance.available;

  @override
  Widget build(BuildContext context) {
    return WingetDBTablePage(
      dbTable: dbTable,
      title: Routes.searchPage.title,
      menuOptions: const PackageListMenuOptions(
        onlyWithSourceButton: false,
        sortOptions: [
          SortBy.name,
          SortBy.publisher,
          SortBy.source,
          SortBy.id,
          SortBy.version,
          SortBy.auto,
          SortBy.random,
        ],
        deepSearchButton: true,
      ),
      packageOptions: const PackageListPackageOptions(
        isInstalled: WingetDB.isPackageInstalled,
        isUpgradable: WingetDB.isPackageUpgradable,
      ),
    );
  }

  static void Function(String) search(BuildContext context) {
    NavigatorState navigator = Navigator.of(context);
    return (input) {
      navigator.pushNamed(Routes.deepSearchPage.route,
          arguments: RouteParameter(
              commandParameter: [input], titleAddon: "'$input'"));
    };
  }

  factory SearchPage.inRoute([RouteParameter? _]) => SearchPage();
}
