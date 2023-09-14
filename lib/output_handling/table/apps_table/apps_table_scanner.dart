import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/infos/app_attribute.dart';
import 'package:winget_gui/output_handling/table/table_part.dart';
import 'package:winget_gui/output_handling/table/table_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../widget_assets/app_locale.dart';
import 'apps_table_part.dart';

class AppsTableScanner extends TableScanner {
  AppsTableScanner(super.respList, {required this.command});
  List<String> command;

  @override
  bool isSpecificTable(String headerLine, BuildContext context) {
    List<String> columnTitles =
        headerLine.split(' ').map<String>((e) => e.trim()).toList();
    AppLocalizations locale = AppLocale.of(context).getWingetAppLocalization() ??
        AppLocalizations.of(context)!;
    return (columnTitles.contains(AppAttribute.name.key(locale)) &&
        columnTitles.contains(AppAttribute.id.key(locale)));
  }

  @override
  TablePart tablePart(List<String> tableLines, AppLocalizations wingetLocale) =>
      AppsTablePart(tableLines, command: command, wingetLocale: wingetLocale);
}
