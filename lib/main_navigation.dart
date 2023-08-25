import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/routes.dart';
import 'package:winget_gui/winget_commands.dart';
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
    Routes.help,
    Routes.sources,
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
          //autoSuggestBox:
          // _searchField(
          //   Winget.search, AppLocalizations.of(context)!),
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
      //onTap: () => context.go(winget.route),
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

  TextBox _commandPrompt() {
    TextEditingController controller = TextEditingController();
    return TextBox(
      controller: controller,
      //onSubmitted: (String command) {
      //  setState(
      //    () {
      //      contentHolder!.content
      //          .showResultOfCommand(command.split(' '), title: "'$command'");
      //      controller.clear();
      //      topIndex = null;
      //    },
      //  );
      //},
      prefix: prefixIcon(FluentIcons.command_prompt),
      placeholder: AppLocalizations.of(context)!.runCommand,
    );
  }

  Widget prefixIcon(IconData? icon) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 5),
      child: Icon(icon),
    );
  }

  NavigationAppBar navBar() {
    return NavigationAppBar(
      automaticallyImplyLeading: false,
      title: Text(
        widget.title,
        style: FluentTheme.of(context).typography.body,
      ),
      actions: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 200,
                ),
                SizedBox(
                  width: constraints.maxWidth / 3,
                  child: _searchField(
                      Winget.search, AppLocalizations.of(context)!),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  TextBox _searchField(Winget winget, AppLocalizations local) {
    TextEditingController controller = TextEditingController();
    return TextBox(
      controller: controller,
      //onSubmitted: (input) {
      //  setState(
      //    () {
      //      contentHolder!.content.showResultOfCommand(
      //        [
      //          ...winget.command,
      //          input,
      //        ],
      //        title: winget.titleWithInput(input, localization: local),
      //      );
      //      controller.clear();
      //      topIndex = null;
      //    },
      //  );
      //},
      //prefix: prefixIcon(winget.icon),
      placeholder: winget.title(local),
    );
  }
}
