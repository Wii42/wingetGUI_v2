import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_builder.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_parser.dart';

import '../output_handling/package_infos/package_infos_peek.dart';
import '../output_handling/table/apps_table/package_peek.dart';
import '../winget_db/db_table.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PackagePeekListView extends StatefulWidget {
  final DBTable dbTable;
  final bool Function(PackageInfosPeek package, DBTable table) showIsInstalled;
  final bool Function(PackageInfosPeek package, DBTable table) showIsUpgradable;
  final Stream<String>? reloadStream;
  final bool showOnlyWithSourceButton;
  final bool onlyWithSourceInitialValue;
  final bool showOnlyWithExactVersionButton;
  final bool onlyWithExactVersionInitialValue;
  const PackagePeekListView(
      {super.key,
      required this.dbTable,
      this.showIsInstalled = defaultFalse,
      this.showIsUpgradable = defaultFalse,
      this.reloadStream,
      this.showOnlyWithSourceButton = true,
      this.onlyWithSourceInitialValue = false,
      this.showOnlyWithExactVersionButton = false,
      this.onlyWithExactVersionInitialValue = false});

  @override
  State<PackagePeekListView> createState() => _PackagePeekListViewState();

  static bool defaultFalse(PackageInfosPeek _, DBTable __) => false;
}

class _PackagePeekListViewState extends State<PackagePeekListView> {
  TextEditingController filterController = TextEditingController();
  late bool onlyWithSource;
  late bool onlyWithExactVersion;

  @override
  void initState() {
    super.initState();
    onlyWithSource = widget.onlyWithSourceInitialValue;
    onlyWithExactVersion = widget.onlyWithExactVersionInitialValue;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return StreamBuilder<String>(
        stream: widget.reloadStream ?? widget.dbTable.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != '') {
            return Center(child: Text(snapshot.data!));
          }
          List<PackageInfosPeek> packages = shownPackages();
          return Column(
            children: [
              topRow(context),
              Expanded(
                child: Stack(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildListView(packages),
                    if (widget.dbTable.hints.isNotEmpty)
                      hintsAndWarnings(context),
                    numberOfAppsText(packages.length, locale),
                  ].withSpaceBetween(height: 5),
                ),
              ),
            ],
          );
        });
  }

  Padding hintsAndWarnings(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: [
          for (OneLineInfo hint in widget.dbTable.hints)
            OneLineInfoBuilder.oneLineInfo(hint, context, onClose: () {}),
        ],
      ),
    );
  }

  Positioned numberOfAppsText(int numberOfShownApps, AppLocalizations locale) {
    return Positioned(
        bottom: 0,
        right: 0,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(locale.nrOfPackagesShown(
              numberOfShownApps, widget.dbTable.infos.length)),
        ));
  }

  ListView buildListView(List<PackageInfosPeek> packages) {
    return ListView.builder(
        itemBuilder: (context, index) {
          PackageInfosPeek package = packages[index];
          if (!package.checkedForScreenshots) {
            package.setImplicitInfos();
          }
          bool installed = widget.showIsInstalled(package, widget.dbTable);
          bool upgradable = widget.showIsUpgradable(package, widget.dbTable);
          return wrapInPadding(
              buildPackagePeek(package, installed, upgradable));
        },
        itemCount: packages.length,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        prototypeItem: wrapInPadding(PackagePeek.prototypeWidget));
  }

  List<PackageInfosPeek> shownPackages() {
    List<PackageInfosPeek> packages = widget.dbTable.infos;
    if (onlyWithSource) {
      packages = packages.where((element) => element.hasKnownSource()).toList();
    }
    if (onlyWithExactVersion) {
      packages = packages.where((element) => element.hasSpecificVersion()).toList();
    }
    if (filter.isNotEmpty) {
      packages = packages
          .where((element) =>
              (element.name?.value.containsCaseInsensitive(filter) ?? false) ||
              (element.id?.value.containsCaseInsensitive(filter) ?? false))
          .toList();
    }
    return packages;
  }

  Widget wrapInPadding(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: child,
    );
  }

  Widget buildPackagePeek(
      PackageInfosPeek package, bool installed, bool upgradable) {
    return PackagePeek(
      package,
      installButton: !installed,
      uninstallButton: installed,
      upgradeButton: upgradable,
    );
  }

  Widget topRow(BuildContext context) {
    List<Widget> children = [
      if (widget.showOnlyWithSourceButton)
        Checkbox(
          checked: onlyWithSource,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                onlyWithSource = value;
              });
            }
          },
          content: const Text('only with source'),
        ),
      if (widget.showOnlyWithExactVersionButton)
        Checkbox(
          checked: onlyWithExactVersion,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                onlyWithExactVersion = value;
              });
            }
          },
          content: const Text('only with exact version'),
        ),
      if (widget.dbTable.infos.length >= 5) filterField(),
    ];

    return Padding(
      padding: EdgeInsets.all(children.isNotEmpty ? 10 : 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }

  Widget filterField() {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: TextFormBox(
          controller: filterController,
          prefix: Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: Text(locale.filterFor),
          ),
          onChanged: (_) {
            setState(() {});
          }),
    );
  }

  String get filter => filterController.text;
}
