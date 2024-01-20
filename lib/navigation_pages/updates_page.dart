import 'package:fluent_ui/fluent_ui.dart';

import '../main.dart';
import '../widget_assets/package_list_page.dart';
import '../widget_assets/package_peek_list_view.dart';
import '../widget_assets/sort_by.dart';
import '../winget_commands.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../winget_db/db_table.dart';

DBTable dbTable = wingetDB.updates;

class UpdatesPage extends StatelessWidget {
  final DBTable dbTable = wingetDB.updates;
  UpdatesPage({super.key});

  static Widget inRoute([dynamic parameters]) {
    return UpdatesPage();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return PackageListPage(
      title: Winget.updates.title(locale),
      listView: PackagePeekListView(
        dbTable: dbTable,
        showIsInstalled: (_, __) => true,
        showIsUpgradable: (_, __) => true,
        showOnlyWithSourceButton: false,
        showOnlyWithExactVersionButton: true,
        onlyWithExactVersionInitialValue: true,
        sortOptions: const [
          SortBy.name,
          SortBy.publisher,
          SortBy.id,
          SortBy.version,
          SortBy.auto,
        ],
      ),
      customReload: () => dbTable.reloadFuture(locale),
    );
  }
}
