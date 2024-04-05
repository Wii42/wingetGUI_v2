import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';
import 'package:winget_gui/package_tables/package_tables.dart';
import 'package:winget_gui/package_tables/winget_table.dart';
import 'package:winget_gui/routes.dart';
import 'package:winget_gui/widget_assets/package_peek_list_view.dart';
import 'package:winget_gui/widget_assets/sort_by.dart';
import 'package:winget_gui/widget_assets/winget_db_table_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();

  static void Function(String) search(BuildContext context,
      {bool Function(PackageInfosPeek)? packageFilter}) {
    NavigatorState navigator = Navigator.of(context);
    return (input) {
      navigator.pushNamed(Routes.deepSearchPage.route,
          arguments: SearchRouteParameter(
              commandParameter: [input],
              titleAddon: "'$input'",
              packageFilter: packageFilter));
    };
  }

  factory SearchPage.inRoute([RouteParameter? _]) => const SearchPage();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController controller;
  final WingetTable dbTable = PackageTables.instance.available;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return WingetDBTablePage(
      dbTable: dbTable,
      title: Routes.searchPage.title,
      menuOptions: const PackageListMenuOptions(
        onlyWithSourceButton: false,
        sortOptions: [
          SortBy.name,
          SortBy.publisher,
          SortBy.source,
          SortBy.id,
          SortBy.version,
          SortBy.auto,
          SortBy.random,
        ],
        deepSearchButton: true,
      ),
      packageOptions: const PackageListPackageOptions(
        isInstalled: PackageTables.isPackageInstalled,
        isUpgradable: PackageTables.isPackageUpgradable,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
