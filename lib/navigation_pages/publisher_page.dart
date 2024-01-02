import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/package_peek_list_view.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';
import 'package:winget_gui/winget_db.dart';

import '../helpers/route_parameter.dart';
import '../main.dart';

class PublisherPage extends StatelessWidget {
  final String publisherId;

  const PublisherPage({super.key, required this.publisherId});

  static Widget inRoute(RouteParameter? parameters) {
    if (parameters! is! StringRouteParameter) {
      throw (Exception(
          'Invalid route parameters, must be StringRouteParameter'));
    }
    String publisherId = (parameters as StringRouteParameter).string;

    return PublisherPage(publisherId: publisherId);
  }

  @override
  Widget build(BuildContext context) {
    return PaneItemBody(
        title: publisherId,
        child: PackagePeekListView(
          dbTable: DBTable(wingetDB.available.infos
              .where((element) => element.publisherID == publisherId)
              .toList()),
        ));
  }
}
