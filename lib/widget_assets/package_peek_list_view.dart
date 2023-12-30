import 'package:fluent_ui/fluent_ui.dart';

import '../main.dart';
import '../output_handling/package_infos/package_infos_peek.dart';
import '../output_handling/table/apps_table/package_peek.dart';
import '../winget_db.dart';

class PackagePeekListView extends StatelessWidget {
  final DBTable dbTable;
  final bool Function(PackageInfosPeek package, DBTable table) isInstalled;
  final bool Function(PackageInfosPeek package, DBTable table) isUpgradable;
  const PackagePeekListView(
      {super.key,
      required this.dbTable,
      required this.isInstalled,
      required this.isUpgradable});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: (context, index) {
          PackageInfosPeek package = dbTable.infos[index];
          bool installed = isInstalled(package, dbTable);
          bool upgradable = isUpgradable(package, dbTable);
          return wrapInPadding(buildPackagePeek(package, installed, upgradable));
        },
        itemCount: dbTable.infos.length,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        prototypeItem: wrapInPadding(PackagePeek.prototypeWidget));
  }

  Widget wrapInPadding(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: child,
    );
  }

  Widget buildPackagePeek(
      PackageInfosPeek package, bool installed, bool upgradable) {
    return PackagePeek(
      package,
      installButton: !installed,
      uninstallButton: installed,
      upgradeButton: upgradable,
    );
  }
}
