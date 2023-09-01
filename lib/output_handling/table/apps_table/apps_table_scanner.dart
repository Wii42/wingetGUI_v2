import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/infos/app_attribute.dart';
import 'package:winget_gui/output_handling/table/table_part.dart';
import 'package:winget_gui/output_handling/table/table_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'apps_table_part.dart';

class AppsTableScanner extends TableScanner {
  AppsTableScanner(super.respList, {required super.command});

  @override
  bool isSpecificTable(String headerLine, BuildContext context) {
    List<String> columnTitles =
        headerLine.split(' ').map<String>((e) => e.trim()).toList();
    AppLocalizations locale = AppLocalizations.of(context)!;
    return (columnTitles.contains(AppAttribute.name.key(locale)) &&
        columnTitles.contains(AppAttribute.id.key(locale)));
  }

  @override
  TablePart tablePart(List<String> tableLines, AppLocalizations locale) =>
      AppsTablePart(tableLines, command: command, locale: locale);
}
