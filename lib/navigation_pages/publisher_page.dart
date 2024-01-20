import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/package_screenshots_list.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';
import 'package:winget_gui/output_handling/show/compartments/title_widget.dart';
import 'package:winget_gui/widget_assets/favicon_widget.dart';
import 'package:winget_gui/widget_assets/package_peek_list_view.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';

import '../helpers/route_parameter.dart';
import '../main.dart';
import '../widget_assets/package_list_page.dart';
import '../widget_assets/sort_by.dart';
import '../winget_db/db_table.dart';

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
    return PackageListPage(
      title: publisherId,
      bodyHeader: publisherTitle(context),
      listView: PackagePeekListView(
        dbTable: DBTable(
          wingetDB.available.infos
              .where((element) => element.publisherID == publisherId)
              .toList(),
          content: 'publisher',
          wingetCommand: [],
        ),
        reloadStream: wingetDB.available.stream,
        showOnlyWithSourceButton: false,
        sortOptions: const [
          SortBy.name,
          SortBy.source,
          SortBy.id,
          SortBy.version,
          SortBy.auto,
        ],
      ),
    );
  }

  Widget publisherTitle(BuildContext context) {
    Typography typography = FluentTheme.of(context).typography;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          FaviconWidget(
            infos: PackageInfosPeek(),
            iconUrl:
                PackageScreenshotsList.instance.publisherIcons[publisherId],
            faviconSize: TitleWidget.faviconSize(),
          ),
          Expanded(
            child: Text(
              publisherId,
              style: typography.titleLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
