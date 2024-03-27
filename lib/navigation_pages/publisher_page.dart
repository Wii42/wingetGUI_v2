import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/package_screenshots_list.dart';
import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';
import 'package:winget_gui/output_handling/show/compartments/title_widget.dart';
import 'package:winget_gui/widget_assets/app_icon.dart';
import 'package:winget_gui/widget_assets/package_peek_list_view.dart';

import '../helpers/json_publisher.dart';
import '../helpers/route_parameter.dart';
import '../widget_assets/package_list_page.dart';
import '../widget_assets/sort_by.dart';
import '../winget_db/db_table.dart';
import '../winget_db/winget_db.dart';

class PublisherPage extends StatelessWidget {
  final String publisherId;
  final String? publisherName;

  const PublisherPage(
      {super.key, required this.publisherId, this.publisherName});

  static Widget inRoute(RouteParameter? parameters) {
    if (parameters! is! StringRouteParameter) {
      throw (Exception(
          'Invalid route parameters, must be StringRouteParameter'));
    }
    String publisherId = (parameters as StringRouteParameter).string;
    String? publisherName = parameters.titleAddon ??
        PackageScreenshotsList
            .instance.publisherIcons[publisherId]?.nameUsingDefaultSource;

    return PublisherPage(
        publisherId: publisherId, publisherName: publisherName);
  }

  @override
  Widget build(BuildContext context) {
    return PackageListPage(
      title: publisherName ?? publisherId,
      bodyHeader: publisherTitle(context),
      listView: PackagePeekListView(
        dbTable: DBTable(
          WingetDB.instance.available.infos
              .where((element) => element.publisher?.id == publisherId)
              .toList(),
          content: (locale) =>
              locale.infoTitle(PackageAttribute.publisher.name),
          wingetCommand: [],
        ),
        customReloadStream: WingetDB.instance.available.stream,
        menuOptions: const PackageListMenuOptions(
          onlyWithSourceButton: false,
          sortOptions: [
            SortBy.name,
            SortBy.source,
            SortBy.id,
            SortBy.version,
            SortBy.auto,
          ],
        ),
        packageOptions: const PackageListPackageOptions(
          isInstalled: WingetDB.isPackageInstalled,
          isUpgradable: WingetDB.isPackageUpgradable,
        ),
      ),
    );
  }

  Widget publisherTitle(BuildContext context) {
    Typography typography = FluentTheme.of(context).typography;
    JsonPublisher? publisher =
        PackageScreenshotsList.instance.publisherIcons[publisherId];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          AppIcon(
            iconUrls: [
              publisher?.solidIconUsingDefaultSource,
              publisher?.iconUsingDefaultSource
            ],
            iconSize: TitleWidget.faviconSize(),
          ),
          Expanded(
            child: Text(
              publisherName ?? publisherId,
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
