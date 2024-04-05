import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';

import 'package:winget_gui/db/package_db.dart';
import 'package:winget_gui/helpers/route_parameter.dart';

class DBTableWidget extends StatelessWidget {
  final DBTable table;
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
              //Button(onPressed: () {  },
              //child: Text('toJson'),)
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                Table(
                  children: [
                    if (table.entries.isNotEmpty)
                      TableRow(children: [
                        for (String s in table.toMap((
                          table.entries.entries.first.key,
                          table.entries.entries.first.value
                        )).keys)
                          Text(s,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                    for (MapEntry e in table.entries.entries)
                      TableRow(children: [
                        for (dynamic s in table.toMap((e.key, e.value)).values)
                          Text(s.toString())
                      ])
                  ],
                ), //Text(jsonEncode(table.entries.entries.map((e) => table.toMap((e.key, e.value))).toList())),
              ]),
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
    DBTable table = parameters.dbTable;
    return DBTableWidget(table);
  }
}
