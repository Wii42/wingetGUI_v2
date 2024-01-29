import 'dart:collection';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/navigation_pages/search_page.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_builder.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_parser.dart';
import 'package:winget_gui/widget_assets/sort_by.dart';
import 'package:winget_gui/winget_db/db_message.dart';

import '../output_handling/package_infos/package_infos.dart';
import '../output_handling/package_infos/package_infos_peek.dart';
import '../output_handling/table/apps_table/package_peek.dart';
import '../winget_db/db_table.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PackagePeekListView extends StatefulWidget {
  final DBTable dbTable;
  late final Stream<DBMessage> reloadStream;
  final PackageListMenuOptions menuOptions;
  final PackageListPackageOptions packageOptions;

  PackagePeekListView({
    super.key,
    required this.dbTable,
    Stream<DBMessage>? customReloadStream,
    this.menuOptions = const PackageListMenuOptions(),
    this.packageOptions = const PackageListPackageOptions(),
  }) {
    reloadStream = customReloadStream ?? dbTable.stream;
  }

  @override
  State<PackagePeekListView> createState() => _PackagePeekListViewState();

  static bool defaultFalse(PackageInfos _) => false;
}

class _PackagePeekListViewState extends State<PackagePeekListView> {
  TextEditingController filterController = TextEditingController();
  late bool onlyWithSource;
  late bool onlyWithExactVersion;
  late SortBy sortBy;
  late bool sortReversed;

  @override
  void initState() {
    super.initState();
    onlyWithSource = widget.menuOptions.onlyWithSourceInitialValue;
    onlyWithExactVersion = widget.menuOptions.onlyWithExactVersionInitialValue;
    sortBy = widget.menuOptions.defaultSortBy;
    sortReversed = widget.menuOptions.sortDefaultReversed;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return StreamBuilder<DBMessage>(
        stream: widget.reloadStream,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data?.status != DBStatus.ready &&
              widget.dbTable.infos.isEmpty) {
            return Center(child: Text(snapshot.data!.message ?? ''));
          }
          if (widget.dbTable.infos.isEmpty) {
            return const Center(child: Text('No Apps found'));
          }
          List<PackageInfosPeek> packages = filterPackages();
          packages = sortPackages(packages, sortBy);
          if (sortReversed) {
            packages = packages.reversed.toList();
          }
          return Column(
            children: [
              topRow(context),
              Expanded(
                child: Stack(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (packages.isNotEmpty)
                      buildListView(packages)
                    else
                      const Center(child: Text('No fittig packages found')),
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
            OneLineInfoWidget(hint, onClose: () {}),
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
          bool installed = widget.packageOptions.isInstalled(package);
          bool upgradable = widget.packageOptions.isUpgradable(package);
          return wrapInPadding(
              buildPackagePeek(package, installed, upgradable));
        },
        itemCount: packages.length,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        prototypeItem: wrapInPadding(PackagePeek.prototypeWidget));
  }

  List<PackageInfosPeek> filterPackages() {
    List<PackageInfosPeek> packages = widget.dbTable.infos;
    if (onlyWithSource) {
      packages = packages.where((element) => element.hasKnownSource()).toList();
    }
    if (onlyWithExactVersion) {
      packages =
          packages.where((element) => element.hasSpecificVersion()).toList();
    }
    if (filter.isNotEmpty) {
      packages = packages
          .where((element) =>
              (element.name?.value.containsCaseInsensitive(filter) ?? false) ||
              (element.id?.value.containsCaseInsensitive(filter) ?? false) ||
              (element.publisherName?.containsCaseInsensitive(filter) ?? false))
          .toList();
    }
    return packages;
  }

  List<PackageInfosPeek> sortPackages(
      List<PackageInfosPeek> packages, SortBy sortBy) {
    if (packages is UnmodifiableListView) {
      packages = List.of(packages);
    }
    return sortBy.sort(packages);
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
      showMatch: widget.packageOptions.showMatch,
      showInstalledIcon: installed && widget.packageOptions.showInstalledIcon,
    );
  }

  Widget topRow(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    List<Widget> children = [
      if (widget.menuOptions.onlyWithSourceButton)
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
      if (widget.menuOptions.onlyWithExactVersionButton)
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
      if (widget.dbTable.infos.length >= 5 &&
          widget.menuOptions.filterField) ...[
        filterField(),
        if (widget.menuOptions.deepSearchButton) deepSearchButton()
      ],
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sort by:'),
          ComboBox<SortBy>(
            items: [
              for (SortBy value in widget.menuOptions.sortOptions)
                ComboBoxItem(value: value, child: Text(value.title(locale))),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  sortBy = value;
                });
              }
            },
            placeholder: Text(sortBy.title(locale)),
          ),
          IconButton(
              icon: Icon(
                  sortReversed ? FluentIcons.sort_up : FluentIcons.sort_down),
              onPressed: () => setState(() => sortReversed = !sortReversed)),
        ].withSpaceBetween(width: 5),
      ),
    ];

    return Padding(
      padding: EdgeInsets.all(children.isNotEmpty ? 10 : 0),
      child: Wrap(
        spacing: 20,
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

  Widget deepSearchButton() {
    return FilledButton(
        onPressed: () => SearchPage.search(context)(filter),
        child: const Text('Deep Search'));
  }

  String get filter => filterController.text;
}

class PackageListMenuOptions {
  final bool onlyWithSourceButton;
  final bool onlyWithSourceInitialValue;
  final bool onlyWithExactVersionButton;
  final bool onlyWithExactVersionInitialValue;
  final SortBy defaultSortBy;
  final List<SortBy> sortOptions;
  final bool sortDefaultReversed;
  final bool deepSearchButton;
  final bool filterField;

  const PackageListMenuOptions({
    this.onlyWithSourceButton = true,
    this.onlyWithSourceInitialValue = false,
    this.onlyWithExactVersionButton = false,
    this.onlyWithExactVersionInitialValue = false,
    this.defaultSortBy = SortBy.auto,
    this.sortOptions = SortBy.values,
    this.sortDefaultReversed = false,
    this.deepSearchButton = false,
    this.filterField = true,
  });
}

class PackageListPackageOptions {
  final bool Function(PackageInfos package) isInstalled;
  final bool Function(PackageInfosPeek package) isUpgradable;
  final bool showMatch;
  final bool showInstalledIcon;

  const PackageListPackageOptions({
    this.isInstalled = PackagePeekListView.defaultFalse,
    this.isUpgradable = PackagePeekListView.defaultFalse,
    this.showMatch = false,
    this.showInstalledIcon = true,
  });
}
