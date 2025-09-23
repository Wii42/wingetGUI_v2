import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/db/package_tables.dart';
import 'package:winget_gui/db/winget_table.dart';
import 'package:winget_gui/widget_assets/package_peek_list_view.dart';
import 'package:winget_gui/widget_assets/sort_by.dart';
import 'package:winget_gui/widget_assets/winget_db_table_page.dart';
import 'package:winget_gui/winget_client/winget_command.dart';
import 'package:winget_gui/winget_commands.dart';

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
        runActionOnAllPackagesButtons: [CmdUpdate('')],
      ),
      packageOptions: PackageListPackageOptions(
        isInstalled: (_) => true,
        isUpgradable: (_) => true,
      ),
    );
  }
}
