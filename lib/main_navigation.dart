import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'content/process_starter.dart';

class MainNavigation extends StatefulWidget {
  MainNavigation({super.key, required this.title});
  final String title;

  final List<Winget> mainItems = [Winget.updates, Winget.installed];
  final List<Winget> footerItems = [
    Winget.about,
    Winget.help,
    Winget.sources,
    Winget.settings
  ];

  List<Winget> get allItems => [...mainItems, ...footerItems];

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  late Map<Winget, Navigator> navigators;
  int? topIndex = 0;

  @override
  void initState() {
    super.initState();
    navigators = {
      for (Winget winget in widget.allItems) winget: navigator(winget)
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
          autoSuggestBox: _commandPrompt(),
          autoSuggestBoxReplacement: const Icon(FluentIcons.command_prompt),
          items: [
            ...createNavItems(widget.mainItems),
            //HistoryTab(contentHolder!, local),
          ],
          footerItems: [...createNavItems(widget.footerItems)],
          selected: topIndex,
          onChanged: (index) {
            setState(() => topIndex = index);
          },
        ),
      );
    });
  }

  List<PaneItem> createNavItems(List<Winget> commands) {
    return [for (Winget winget in commands) _navButton(winget)];
  }

  PaneItem _navButton(Winget winget) {
    AppLocalizations local = AppLocalizations.of(context)!;
    return PaneItem(
      title: Text(winget.title(local)),
      icon: Icon(winget.icon),
      body: navigators[winget] ?? notFoundMessage(),
      //onTap: () => context.go(winget.route),
    );
  }

  Navigator navigator(Winget winget) {
    return Navigator(
      initialRoute: winget.route,
      onGenerateInitialRoutes: (_, __) => [
        FluentPageRoute<dynamic>(builder: (context) {
          return ProcessStarter(
            command: winget.command,
            winget: winget,
          );
        })
      ],
      onGenerateRoute: (settings) {
        Widget? page;
        for (Winget route in Winget.values) {
          if (settings.name == route.route) {
            page = ProcessStarter(
              command: winget.command,
              winget: winget,
            );
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
      prefix: prefixIcon(winget.icon),
      placeholder: winget.title(local),
    );
  }
}
