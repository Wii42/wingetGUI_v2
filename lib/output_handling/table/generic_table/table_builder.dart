import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;

import '../../../helpers/extensions/string_extension.dart';
import '../../../widget_assets/decorated_card.dart';
import '../../../widget_assets/inline_link_button.dart';
import '../../output_builder.dart';
import '../table_parser.dart';

class TableBuilder extends OutputBuilder {
  final TableData tableData;

  TableBuilder(this.tableData);

  @override
  Widget build(BuildContext context) {
    return DecoratedCard(
      child: material.DataTable(
        columns: tableColumns(tableData),
        rows: tableRows(tableData),
        columnSpacing: 20,
      ),
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
        ? InlineLinkButton(url: Uri.parse(text), text: Text(text))
        : Text(text);
  }
}
