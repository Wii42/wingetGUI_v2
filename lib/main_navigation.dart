import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainNavigation extends StatefulWidget {
  MainNavigation({super.key, required this.title});
  final String title;

  final List<Routes> mainItems = [
    Routes.updates,
    Routes.installed,
    Routes.searchPage
  ];

  static const List<Routes> advancedFooterItems = [
    Routes.about,
    Routes.sources,
    Routes.commandPromptPage
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

class MainNavigationState extends State<MainNavigation> {
  late Map<Routes, Navigator> navigators;
  int? topIndex = 0;

  @override
  void initState() {
    super.initState();
    navigators = {
      for (Routes route in widget.allItems) route: navigator(route)
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return NavigationView(
        appBar: constraints.maxWidth <= 640
            ? NavigationAppBar(
                automaticallyImplyLeading: false, title: Text(widget.title))
            : null,
        pane: NavigationPane(
          header:  Padding(
            padding: const EdgeInsets.all(10),
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

  PaneItemAction buildPaneItemAction() => PaneItemAction(
      icon: const Icon(FluentIcons.add), title: const Text('hi'), onTap: () {});

  List<NavigationPaneItem> createNavItems(List<Routes> commands) {
    return [for (Routes winget in commands) _navItem(winget)];
  }

  PaneItem _navItem(Routes route) {
    AppLocalizations local = AppLocalizations.of(context)!;
    return PaneItem(
      title: Text(route.title(local)),
      icon: Icon(route.icon),
      body: navigators[route] ?? notFoundMessage(),
    );
  }

  PaneItem _navExpander(Routes route, List<Routes> children) {
    AppLocalizations local = AppLocalizations.of(context)!;
    return PaneItemExpander(
      title: Text(route.title(local)),
      icon: Icon(route.icon),
      body: navigators[route] ?? notFoundMessage(),
      items: createNavItems(children),
    );
  }

  Navigator navigator(Routes winget) {
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

  Center notFoundMessage() => const Center(child: Text('Oops, page not found'));
}
