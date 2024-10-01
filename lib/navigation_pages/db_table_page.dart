import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/persistent_storage/persistent_storage_interface.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';

import 'package:winget_gui/helpers/route_parameter.dart';

class DBTableWidget extends StatelessWidget {
  final TableRepresentation table;
  const DBTableWidget(this.table, {super.key});

  @override
  Widget build(BuildContext context) {
    return PaneItemBody(
      title: 'DBTable ${table.tableName}',
      child: Column(
        children: [
          Row(
            children: [
              Text('Entries: ${table.entries.length}'),
              Button(
                onPressed: () {
                  table.deleteAllEntries();
                },
                child: const Text('Delete All Entries'),
              ),
              Button(
                onPressed: () async {
                  String? outputFile = await FilePicker.platform.saveFile(
                    dialogTitle: 'Please select an output folder:',
                    fileName: '${table.tableName}.json',
                    allowedExtensions: ['json'],
                  );

                  if (outputFile != null) {
                    await File(outputFile).writeAsString(table.toJsonString());
                  }
                },
                child: const Text('Save Json file'),
              ),
            ].withSpaceBetween(width: 10),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Table(
                    children: [
                      if (table.entries.isNotEmpty)
                        TableRow(children: [
                          for (String s in table.entryToMap((
                            table.entries.entries.first.key,
                            table.entries.entries.first.value
                          )).keys)
                            Text(s,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                        ]),
                      for (MapEntry e in table.entries.entries)
                        TableRow(children: [
                          for (dynamic s
                              in table.entryToMap((e.key, e.value)).values)
                            Text(s.toString())
                        ])
                    ],
                  ),
                  //Text(table.toJson())
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget inRoute(RouteParameter? parameters) {
    if (parameters == null) {
      throw Exception("Route parameter of DBTableWidget must not be null null");
    }
    if (parameters is! DBRouteParameter) {
      throw Exception(
          "Route parameter of DBTableWidget must be of type DBRouteParameter");
    }
    TableRepresentation table = parameters.dbTable;
    return DBTableWidget(table);
  }
}
