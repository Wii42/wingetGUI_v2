import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/db/winget_table.dart';
import 'package:winget_gui/output_handling/output_handler.dart';

import 'package_list_page.dart';
import 'package_peek_list_view.dart';

class WingetDBTablePage extends StatelessWidget {
  final WingetTable dbTable;
  final String Function(AppLocalizations)? title;
  final IconData? icon;
  final PackageListMenuOptions menuOptions;
  final PackageListPackageOptions packageOptions;

  const WingetDBTablePage({
    super.key,
    required this.dbTable,
    required this.title,
    this.menuOptions = const PackageListMenuOptions(),
    this.packageOptions = const PackageListPackageOptions(),
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    AppLocalizations wingetLocale = OutputHandler.getWingetLocale(context);
    return PackageListPage(
      title: (title != null) ? title!(locale) : null,
      icon: icon,
      listView: PackagePeekListView(
        dbTable: dbTable,
        menuOptions: menuOptions,
        packageOptions: packageOptions,
      ),
      customReload: () => dbTable.reloadFuture(wingetLocale),
    );
  }
}
