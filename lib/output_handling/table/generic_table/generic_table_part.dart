import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:winget_gui/widget_assets/link_button.dart';

import '../../../helpers/extensions/string_extension.dart';
import '../table_part.dart';

class GenericTablePart extends TablePart {
  GenericTablePart(super.lines,
      {required super.command, required super.locale});

  @override
  Widget buildTableRepresentation(List<Map<String, String>> tableData) {
    return material.DataTable(
      columns: tableColumns(tableData),
      rows: tableRows(tableData),
    );
  }

  List<material.DataColumn> tableColumns(List<Map<String, String>> tableData) {
    return [
      for (String columnName in tableData.first.keys)
        material.DataColumn(label: Text(columnName))
    ];
  }

  List<material.DataRow> tableRows(List<Map<String, String>> tableData) {
    return [
      for (Map<String, String> dataRow in tableData)
        material.DataRow(cells: tableEntry(tableData, dataRow))
    ];
  }

  List<material.DataCell> tableEntry(
      List<Map<String, String>> tableData, Map<String, String> dataRow) {
    return [
      for (String column in tableData.first.keys)
        material.DataCell(tableCell(dataRow[column]!))
    ];
  }

  Widget tableCell(String text) {
    return (isLink(text))
        ? LinkButton(url: Uri.parse(text), text: Text(text))
        : Text(text);
  }
}
