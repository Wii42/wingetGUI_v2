import 'package:fluent_ui/fluent_ui.dart';

import '../main.dart';
import '../widget_assets/package_peek_list_view.dart';
import '../widget_assets/pane_item_body.dart';
import '../widget_assets/sort_by.dart';
import '../winget_commands.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../winget_db/db_table.dart';

class InstalledPage extends StatelessWidget {
  final DBTable dbTable = wingetDB.installed;
  InstalledPage({super.key});

  static Widget inRoute([dynamic parameters]) {
    return InstalledPage();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return PaneItemBody(
      title: Winget.installed.title(locale),
      child: PackagePeekListView(
        dbTable: dbTable,
        showIsInstalled: (_, __) => true,
        showIsUpgradable: (package, __) => package.hasAvailableVersion(),
        sortOptions: const [
          SortBy.name,
          SortBy.publisher,
          SortBy.source,
          SortBy.id,
          SortBy.version,
          SortBy.auto,
        ],
      ),
      customReload: () => dbTable.reloadFuture(locale),
    );
  }
}
