import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/db/db_message.dart';
import 'package:winget_gui/db/package_db.dart' as favicon_db;
import 'package:winget_gui/db/package_tables.dart';
import 'package:winget_gui/db/winget_table.dart';
import 'package:winget_gui/helpers/json_publisher.dart';
import 'package:winget_gui/helpers/package_screenshots_list.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/package_infos/package_attribute.dart';
import 'package:winget_gui/widget_assets/app_icon.dart';
import 'package:winget_gui/widget_assets/package_list_page.dart';
import 'package:winget_gui/widget_assets/package_long_info/title_widget.dart';
import 'package:winget_gui/widget_assets/package_peek_list_view.dart';
import 'package:winget_gui/widget_assets/sort_by.dart';

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
            .instance.publisherIcons[publisherId]?.nameUsingDefaultSource ??
        favicon_db.PackageDB.instance.publisherNamesByPublisherId[publisherId];

    return PublisherPage(
        publisherId: publisherId, publisherName: publisherName);
  }

  @override
  Widget build(BuildContext context) {
    return PackageListPage(
      title: publisherName ?? publisherId,
      bodyHeader: publisherTitle(context),
      listView: PackagePeekListView(
        dbTable: WingetTable(
          PackageTables.instance.available.infos
              .where((element) => element.publisher?.id == publisherId)
              .toList(),
          content: (locale) =>
              locale.infoTitle(PackageAttribute.publisher.name),
          wingetCommand: [],
          status: DBStatus.ready,
        ),
        customReloadStream: PackageTables.instance.available.stream,
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
          isInstalled: PackageTables.isPackageInstalled,
          isUpgradable: PackageTables.isPackageUpgradable,
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
