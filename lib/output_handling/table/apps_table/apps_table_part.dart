import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/table/apps_table/package_list.dart';
import 'package:winget_gui/output_handling/table/apps_table/package_short_info.dart';

import '../../infos/package_infos.dart';
import '../table_part.dart';

class AppsTablePart extends TablePart {
  AppsTablePart(super.lines, {required super.command, required super.locale});

  @override
  Widget buildTableRepresentation(List<Map<String, String>> tableData) {
    List<PackageShortInfo> packages = [];
    for (Map<String, String> tableRow in tableData) {
      packages.add(
        PackageShortInfo(
          PackageInfos.fromMap(details: tableRow, locale: locale),
          command: command,
        ),
      );
    }
    return PackageList(packages, command: command);
  }
}
