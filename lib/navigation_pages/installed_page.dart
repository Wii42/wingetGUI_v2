import 'package:fluent_ui/fluent_ui.dart';

import '../widget_assets/package_list_page.dart';
import '../widget_assets/package_peek_list_view.dart';
import '../widget_assets/sort_by.dart';
import '../winget_commands.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../winget_db/db_table.dart';
import '../winget_db/winget_db.dart';

class InstalledPage extends StatelessWidget {
  final DBTable dbTable = WingetDB.instance.installed;
  InstalledPage({super.key});

  static Widget inRoute([dynamic parameters]) {
    return InstalledPage();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return PackageListPage(
      title: Winget.installed.title(locale),
      listView: PackagePeekListView(
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
