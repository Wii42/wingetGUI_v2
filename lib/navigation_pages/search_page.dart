import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/routes.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';

import '../main.dart';
import '../widget_assets/package_peek_list_view.dart';
import '../widget_assets/sort_by.dart';
import '../winget_db/db_table.dart';

class SearchPage extends StatelessWidget {
  SearchPage({super.key});

  final TextEditingController controller = TextEditingController();
  final DBTable dbTable = wingetDB.available;

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    String title = Routes.searchPage.title(locale);
    return PaneItemBody(
      title: title,
      customReload: () => dbTable.reloadFuture(locale),
      child: PackagePeekListView(
        dbTable: wingetDB.available,
        showIsInstalled: (package, _) =>
            wingetDB.installed.idMap.containsKey(package.id!.value),
        showIsUpgradable: (package, _) => package.availableVersion != null,
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
