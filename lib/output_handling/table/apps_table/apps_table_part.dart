import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/table/apps_table/package_list.dart';
import 'package:winget_gui/output_handling/table/apps_table/package_short_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../infos/package_infos_peek.dart';
import '../table_part.dart';

class AppsTablePart extends TablePart {
  List<String> command;
  AppLocalizations wingetLocale;

  AppsTablePart(super.lines,
      {required this.command, required this.wingetLocale});

  @override
  Widget buildTableRepresentation(List<Map<String, String>> tableData) {
    List<PackageShortInfo> packages = [];
    for (Map<String, String> tableRow in tableData) {
      packages.add(
        PackageShortInfo(
          PackageInfosPeek.fromMap(details: tableRow, locale: wingetLocale),
          command: command,
        ),
      );
    }
    return PackageList(packages, command: command);
  }
}
