import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_builder.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_parser.dart';

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
      this.isInstalled = defaultFalse,
      this.isUpgradable = defaultFalse});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dbTable.hints.isNotEmpty)
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (OneLineInfo hint in dbTable.hints)
                OneLineInfoBuilder.oneLineInfo(hint, context, onClose: () {}),
            ],
          ),
        Expanded(
          child: ListView.builder(
              itemBuilder: (context, index) {
                PackageInfosPeek package = dbTable.infos[index];
                if (!package.checkedForScreenshots) {
                  package.setImplicitInfos();
                }
                bool installed = isInstalled(package, dbTable);
                bool upgradable = isUpgradable(package, dbTable);
                return wrapInPadding(
                    buildPackagePeek(package, installed, upgradable));
              },
              itemCount: dbTable.infos.length,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              prototypeItem: wrapInPadding(PackagePeek.prototypeWidget)),
        ),
        Text("${dbTable.infos.length} Apps"),
      ],
    );
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

  static bool defaultFalse(PackageInfosPeek _, DBTable __) => false;

}
