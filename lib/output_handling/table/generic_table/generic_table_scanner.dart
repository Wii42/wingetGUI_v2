import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/table/generic_table/generic_table_part.dart';
import 'package:winget_gui/output_handling/table/table_part.dart';
import 'package:winget_gui/output_handling/table/table_scanner.dart';

class GenericTableScanner extends TableScanner {
  GenericTableScanner(super.respList);

  @override
  bool isSpecificTable(String headerLine, BuildContext context) {
    return true;
  }

  @override
  TablePart tablePart(List<String> tableLines, AppLocalizations wingetLocale) =>
      GenericTablePart(tableLines);
}
