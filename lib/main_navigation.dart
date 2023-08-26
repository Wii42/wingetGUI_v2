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
  final List<Routes> footerItems = [
    Routes.about,
    Routes.sources,
    Routes.commandPromptPage,
    Routes.settings
  ];

  List<Routes> get allItems => [...mainItems, ...footerItems];

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
      for (Routes winget in widget.allItems) winget: navigator(winget)
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
          header: const Padding(
            padding: EdgeInsets.all(10),
            child: Text('WingetGUI'),
          ),
          items: createNavItems(widget.mainItems),
          footerItems: createNavItems(widget.footerItems),
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

  List<PaneItem> createNavItems(List<Routes> commands) {
    return [for (Routes winget in commands) _navButton(winget)];
  }

  PaneItem _navButton(Routes route) {
    AppLocalizations local = AppLocalizations.of(context)!;
    return PaneItem(
      title: Text(route.title(local)),
      icon: Icon(route.icon),
      body: navigators[route] ?? notFoundMessage(),
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
