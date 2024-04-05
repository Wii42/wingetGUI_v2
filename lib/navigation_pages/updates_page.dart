import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/winget_db_table_page.dart';

import '../widget_assets/package_peek_list_view.dart';
import '../widget_assets/sort_by.dart';
import '../winget_commands.dart';
import '../winget_db/db_table.dart';
import '../winget_db/winget_db.dart';
import '../winget_process/package_action_type.dart';

WingetTable dbTable = PackageTables.instance.updates;

class UpdatesPage extends StatelessWidget {
  final WingetTable dbTable = PackageTables.instance.updates;
  UpdatesPage({super.key});

  static Widget inRoute([dynamic parameters]) {
    return UpdatesPage();
  }

  @override
  Widget build(BuildContext context) {
    return WingetDBTablePage(
      dbTable: dbTable,
      title: Winget.updates.title,
      menuOptions: const PackageListMenuOptions(
        onlyWithSourceButton: false,
        onlyWithExactVersionButton: true,
        onlyWithExactVersionInitialValue: true,
        sortOptions: [
          SortBy.name,
          SortBy.publisher,
          SortBy.id,
          SortBy.version,
          SortBy.auto,
        ],
        runActionOnAllPackagesButtons: [PackageActionType.update],
      ),
      packageOptions: PackageListPackageOptions(
        isInstalled: (_) => true,
        isUpgradable: (_) => true,
      ),
    );
  }
}
