import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/routes.dart';

import '../widget_assets/package_list_page.dart';
import '../widget_assets/package_peek_list_view.dart';
import '../widget_assets/sort_by.dart';
import '../winget_db/db_table.dart';
import '../winget_db/winget_db.dart';

class SearchPage extends StatelessWidget {
  SearchPage({super.key});

  final TextEditingController controller = TextEditingController();
  final DBTable dbTable = WingetDB.instance.available;

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    String title = Routes.searchPage.title(locale);
    return PackageListPage(
      title: title,
      customReload: () => dbTable.reloadFuture(locale),
      listView: PackagePeekListView(
        dbTable: WingetDB.instance.available,
        showIsInstalled: WingetDB.isPackageInstalled,
        showIsUpgradable: WingetDB.isPackageUpgradable,
        showOnlyWithSourceButton: false,
        sortOptions: const [
          SortBy.name,
          SortBy.publisher,
          SortBy.source,
          SortBy.id,
          SortBy.version,
          SortBy.auto,
        ],
        showDeepSearchButton: true,
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
