import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/package_peek_list_view.dart';
import 'package:winget_gui/widget_assets/winget_db_table_page.dart';

import '../widget_assets/sort_by.dart';
import '../winget_commands.dart';

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
    return WingetDBTablePage(
      dbTable: dbTable,
      title: Winget.installed.title,
      menuOptions: const PackageListMenuOptions(
        sortOptions: [
          SortBy.name,
          SortBy.publisher,
          SortBy.source,
          SortBy.id,
          SortBy.version,
          SortBy.auto,
        ],
      ),
      packageOptions: PackageListPackageOptions(
        isInstalled: (_) => true,
        isUpgradable: WingetDB.isPackageUpgradable,
      ),
    );
  }
}
