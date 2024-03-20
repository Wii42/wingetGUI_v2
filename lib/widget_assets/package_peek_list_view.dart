import 'dart:async';
import 'dart:collection';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/navigation_pages/search_page.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_builder.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_parser.dart';
import 'package:winget_gui/widget_assets/decorated_card.dart';
import 'package:winget_gui/widget_assets/sort_by.dart';
import 'package:winget_gui/winget_db/db_message.dart';

import '../output_handling/package_infos/package_infos.dart';
import '../output_handling/package_infos/package_infos_peek.dart';
import '../output_handling/table/package_peek.dart';
import '../winget_db/db_table.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../winget_process/package_action_type.dart';

class PackagePeekListView extends StatefulWidget {
  final DBTable dbTable;
  late final Stream<DBMessage> reloadStream;
  final PackageListMenuOptions menuOptions;
  final PackageListPackageOptions packageOptions;
  final StreamController<String> filterStreamController;

  PackagePeekListView({
    super.key,
    required this.dbTable,
    Stream<DBMessage>? customReloadStream,
    this.menuOptions = const PackageListMenuOptions(),
    this.packageOptions = const PackageListPackageOptions(),
  }) : filterStreamController = StreamController<String>.broadcast() {
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
    setDefaultValues();
    listenToFilterStream();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return StreamBuilder<DBMessage>(
        stream: widget.reloadStream,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data?.status != DBStatus.ready &&
              prefilteredInfos.isEmpty) {
            return Center(child: Text(snapshot.data!.message ?? ''));
          }
          if (prefilteredInfos.isEmpty) {
            return Center(
                child: Text(
              locale.noAppsFound,
            ));
          }
          List<PackageInfosPeek> packages = getVisiblePackages();
          return Column(
            children: [
              menuOptions(context, packages),
              Expanded(
                child: Stack(
                  children: [
                    if (packages.isNotEmpty)
                      buildListView(packages)
                    else
                      Center(child: Text(locale.noFittingAppsFound)),
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

  List<PackageInfosPeek> getVisiblePackages() {
    List<PackageInfosPeek> packages = filterPackages();
    packages = sortPackages(packages, sortBy);
    if (sortReversed) {
      packages = packages.reversed.toList();
    }
    return packages;
  }

  List<PackageInfosPeek> get prefilteredInfos {
    List<PackageInfosPeek> infos = widget.dbTable.infos;
    if (widget.packageOptions.packageFilter != null) {
      return infos.where(widget.packageOptions.packageFilter!).toList();
    }
    return infos;
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
    int totalApps = prefilteredInfos.length;
    return Positioned(
        bottom: 0,
        right: 0,
        child: DecoratedCard(
            solidColor: true,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Text((numberOfShownApps != totalApps)
                  ? locale.nrOfPackagesShown(numberOfShownApps, totalApps)
                  : locale.nrOfPackages(numberOfShownApps)),
            )));
  }

  ListView buildListView(List<PackageInfosPeek> packages) {
    return ListView.builder(
        itemBuilder: buildByIndex(packages),
        itemCount: packages.length,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        prototypeItem: wrapInPadding(PackagePeek.prototypeWidget));
  }

  Widget Function(BuildContext, int) buildByIndex(
      List<PackageInfosPeek> packages) {
    return (BuildContext context, int index) {
      PackageInfosPeek package = packages[index];
      if (!package.checkedForScreenshots) {
        package.setImplicitInfos();
      }
      bool installed = widget.packageOptions.isInstalled(package);
      bool upgradable = widget.packageOptions.isUpgradable(package);
      return wrapInPadding(buildPackagePeek(package, installed, upgradable));
    };
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
      installButton: !installed || widget.packageOptions.showAllButtons,
      uninstallButton: installed || widget.packageOptions.showAllButtons,
      upgradeButton: upgradable || widget.packageOptions.showAllButtons,
      showMatch: widget.packageOptions.showMatch,
      showInstalledIcon: installed && widget.packageOptions.showInstalledIcon,
      defaultSourceIsLocalPC: widget.packageOptions.defaultSourceIsLocalPC,
    );
  }

  List<PackageInfosPeek> filterPackages() {
    List<PackageInfosPeek> packages = prefilteredInfos;
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

  Widget menuOptions(BuildContext context, List<PackageInfos> visiblePackages) {
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
          content: Text(locale.onlyAppsWithSource),
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
          content: Text(locale.onlyAppsWithExactVersion),
        ),
      if (prefilteredInfos.length >= 5 && widget.menuOptions.filterField) ...[
        searchField(),
        if (widget.menuOptions.deepSearchButton) deepSearchButton()
      ],
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(locale.sortBy),
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
          for (PackageActionType action
              in widget.menuOptions.runActionOnAllPackagesButtons)
            packageActionOnAll(visiblePackages, action),
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

  Widget searchField() {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: TextFormBox(
          controller: filterController,
          prefix: Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: Text('${locale.searchFor}:'),
          ),
          onChanged: (_) {
            setState(() {});
          }),
    );
  }

  Widget deepSearchButton() {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return FilledButton(
        onPressed: () => SearchPage.search(context)(filter),
        child: Text(locale.extendedSearch));
  }

  /// button which performs the selected [PackageActionType] ((un-)install/upgrade) on all packages
  Widget packageActionOnAll(
      List<PackageInfos> packages, PackageActionType action) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return FilledButton(
        onPressed: () {
          for (PackageInfos package in packages) {
            action.runAction(package, context);
          }
        },
        child: Text(action.winget.title(locale)));
  }

  String get filter => filterController.text;

  void listenToFilterStream() {
    widget.filterStreamController.stream.listen((event) {
      setState(() {
        filterController.text = event;
        setDefaultValues();
      });
    });
  }

  void setDefaultValues() {
    onlyWithSource = widget.menuOptions.onlyWithSourceInitialValue;
    onlyWithExactVersion = widget.menuOptions.onlyWithExactVersionInitialValue;
    sortBy = widget.menuOptions.defaultSortBy;
    sortReversed = widget.menuOptions.sortDefaultReversed;
  }
}

/// Options for the [PackagePeekList] widget, concerning the menu options bar
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
  final List<PackageActionType> runActionOnAllPackagesButtons;

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
    this.runActionOnAllPackagesButtons = const [],
  });
}

/// Options for the [PackagePeekList] widget, concerning the individual packages
class PackageListPackageOptions {
  final bool Function(PackageInfosPeek package) isInstalled;
  final bool Function(PackageInfosPeek package) isUpgradable;
  final bool showMatch;

  /// Show an icon indicating if the package is installed
  final bool showInstalledIcon;

  /// If true, if [package.source] is null, it defaults to be the local PC
  final bool defaultSourceIsLocalPC;
  final bool Function(PackageInfosPeek)? packageFilter;

  /// If true, all buttons are shown, overriding [isInstalled] and [isUpgradable].
  /// If false, only the necessary buttons are shown
  final bool showAllButtons;

  const PackageListPackageOptions({
    this.isInstalled = PackagePeekListView.defaultFalse,
    this.isUpgradable = PackagePeekListView.defaultFalse,
    this.showMatch = false,
    this.showInstalledIcon = true,
    this.packageFilter,
    this.defaultSourceIsLocalPC = false,
    this.showAllButtons = false,
  });
}
