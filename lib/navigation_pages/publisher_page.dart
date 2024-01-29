import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/package_screenshots_list.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';
import 'package:winget_gui/output_handling/show/compartments/title_widget.dart';
import 'package:winget_gui/widget_assets/favicon_widget.dart';
import 'package:winget_gui/widget_assets/package_peek_list_view.dart';

import '../helpers/route_parameter.dart';
import '../widget_assets/package_list_page.dart';
import '../widget_assets/sort_by.dart';
import '../winget_db/db_table.dart';
import '../winget_db/winget_db.dart';

class PublisherPage extends StatelessWidget {
  final String publisherId;
  final String? publisherName;

  const PublisherPage({super.key, required this.publisherId, this.publisherName});

  static Widget inRoute(RouteParameter? parameters) {
    if (parameters! is! StringRouteParameter) {
      throw (Exception(
          'Invalid route parameters, must be StringRouteParameter'));
    }
    String publisherId = (parameters as StringRouteParameter).string;
    String? publisherName =
        PackageScreenshotsList.instance.publisherIcons[publisherId]?.publisherName;

    return PublisherPage(publisherId: publisherId, publisherName: publisherName);
  }

  @override
  Widget build(BuildContext context) {
    return PackageListPage(
      title: publisherName ?? publisherId,
      bodyHeader: publisherTitle(context),
      listView: PackagePeekListView(
        dbTable: DBTable(
          WingetDB.instance.available.infos
              .where((element) => element.publisherID == publisherId)
              .toList(),
          content: 'publisher',
          wingetCommand: [],
        ),
        reloadStream: WingetDB.instance.available.stream,
        showIsInstalled: WingetDB.isPackageInstalled,
        showIsUpgradable: WingetDB.isPackageUpgradable,
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
            iconUrl: PackageScreenshotsList
                .instance.publisherIcons[publisherId]?.iconUrl,
            faviconSize: TitleWidget.faviconSize(),
          ),
          Expanded(
            child: Text(
              publisherName?? publisherId,
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
