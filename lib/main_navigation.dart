import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/package_actions_widget.dart';
import 'package:winget_gui/routes.dart';

class MainNavigation extends StatefulWidget {
  MainNavigation({super.key, required this.title});
  final String title;

  final List<Routes> mainItems = [
    Routes.updatesPage,
    Routes.installedPage,
    Routes.searchPage,
  ];

  static const List<Routes> advancedFooterItems = [
    Routes.about,
    Routes.sources,
    Routes.commandPromptPage,
    Routes.logsPage
  ];

  final Routes expanderFooterItem = Routes.advancedOptions;

  final List<Routes> otherFooterItems = [Routes.settingsPage];

  List<Routes> get allItems => [
        ...mainItems,
        expanderFooterItem,
        ...advancedFooterItems,
        ...otherFooterItems
      ];

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation>
    with AutomaticKeepAliveClientMixin<MainNavigation> {
  late Map<Routes, Widget> navigators;
  int? topIndex = 0;

  @override
  void initState() {
    super.initState();
    navigators = {
      for (Routes route in widget.allItems) route: NavigationNavigator(route)
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      bool displayModeIsOpen = constraints.maxWidth >= 1008;
      bool displayModeIsMinimal = constraints.maxWidth <= 640;
      return NavigationView(
        contentShape: contentShape(context, displayModeIsMinimal),
        appBar: false
            ? NavigationAppBar(
                automaticallyImplyLeading: false,
                height: 52,
                title: Text(
                  widget.title,
                  style: FluentTheme.of(context)
                      .typography
                      .body
                      ?.merge(const TextStyle(fontWeight: FontWeight.w600)),
                ))
            : null,
        pane: NavigationPane(
          displayMode: displayModeIsOpen
              ? PaneDisplayMode.open
              : PaneDisplayMode.compact,
          header: false
              ? null
              : Padding(
                  padding: const EdgeInsets.all(13.5),
                  child: Text(widget.title),
                ),
          items: createNavItems(widget.mainItems),
          footerItems: [
            _navExpander(
                Routes.advancedOptions, MainNavigation.advancedFooterItems),
            ...createNavItems(widget.otherFooterItems)
          ],
          selected: topIndex,
          onChanged: (index) {
            setState(() => topIndex = index);
          },
        ),
      );
    });
  }

  ShapeBorder contentShape(BuildContext context, bool displayModeIsMinimal) {
    return const RoundedRectangleBorder();
  }

  List<NavigationPaneItem> createNavItems(List<Routes> commands) {
    return [for (Routes winget in commands) _navItem(winget)];
  }

  PaneItem _navItem(Routes route) {
    AppLocalizations local = AppLocalizations.of(context)!;
    return PaneItem(
      title: Text(route.title(local)),
      icon: Icon(route.icon),
      body: PackageActionWrap(navigators[route] ?? notFoundMessage()),
    );
  }

  PaneItem _navExpander(Routes route, List<Routes> children) {
    AppLocalizations local = AppLocalizations.of(context)!;
    return PaneItemExpander(
      title: Text(route.title(local)),
      icon: Icon(route.icon),
      body: PackageActionWrap(navigators[route] ?? notFoundMessage()),
      items: createNavItems(children),
    );
  }

  Widget navigator(Routes winget) {
    return Navigator(
      initialRoute: winget.route,
      onGenerateInitialRoutes: (state, __) => [
        FluentPageRoute<dynamic>(builder: (context) {
          return winget.buildPage();
        })
      ],
      onGenerateRoute: (settings) {
        Widget? page;
        for (Routes route in Routes.values) {
          if (settings.name == route.route) {
            page = route.buildPage(settings.arguments);
          }
        }

        return FluentPageRoute<dynamic>(
          builder: (context) {
            return page ?? notFoundMessage();
          },
          settings: settings,
        );
      },
    );
  }

  static Center notFoundMessage() =>
      const Center(child: Text('Oops, page not found'));

  @override
  bool get wantKeepAlive => true;
}

class PackageActionWrap extends StatelessWidget {
  final Widget child;

  const PackageActionWrap(this.child, {super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          Expanded(child: child),
          PackageActionsList(maxListHeight: constraints.maxHeight / 3)
        ],
      );
    });
  }
}

class NavigationNavigator extends StatefulWidget {
  final Routes winget;
  const NavigationNavigator(this.winget, {super.key});

  @override
  State<StatefulWidget> createState() => _NavigationNavigatorState();
}

class _NavigationNavigatorState extends State<NavigationNavigator>
    with AutomaticKeepAliveClientMixin<NavigationNavigator> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Navigator(
      initialRoute: widget.winget.route,
      onGenerateInitialRoutes: (state, __) => [
        FluentPageRoute<dynamic>(builder: (context) {
          return widget.winget.buildPage();
        })
      ],
      onGenerateRoute: (settings) {
        Widget? page;
        for (Routes route in Routes.values) {
          if (settings.name == route.route) {
            page = route.buildPage(settings.arguments);
          }
        }

        return FluentPageRoute<dynamic>(
          builder: (context) {
            return page ?? MainNavigationState.notFoundMessage();
          },
          settings: settings,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
