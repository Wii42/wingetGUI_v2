import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/package_tables/package_tables.dart';
import 'package:winget_gui/package_tables/winget_table.dart';
import 'package:winget_gui/widget_assets/package_peek_list_view.dart';
import 'package:winget_gui/widget_assets/sort_by.dart';
import 'package:winget_gui/widget_assets/winget_db_table_page.dart';
import 'package:winget_gui/winget_commands.dart';

class InstalledPage extends StatelessWidget {
  final WingetTable dbTable = PackageTables.instance.installed;
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
        isUpgradable: PackageTables.isPackageUpgradable,
        defaultSourceIsLocalPC: true,
      ),
    );
  }
}
