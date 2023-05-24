import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
//import 'package:system_theme/system_theme.dart';
import 'package:winget_gui/content.dart';
import 'package:winget_gui/winget_commands.dart';

import 'content_place.dart';

Future<void> main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  //await Window.initialize();
  //Window.setEffect(effect: WindowEffect.acrylic, color: Colors.black);
  runApp(const WingetGui());
}

class WingetGui extends StatelessWidget {
  const WingetGui({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Flutter Demo',
      theme: FluentThemeData(
        //accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        brightness: Brightness.light,
      ),
      darkTheme: FluentThemeData(
        //accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: "WingetGUI"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ContentPlace contentPlace = _getContentPlace(Content());
  int? topIndex;

  List<NavigationPaneItem> items = [
    //...createNavItems([Winget.updates, Winget.installed])
  ];
  List<NavigationPaneItem> footerItems = [
    //...createNavItems([Winget.about, Winget.help])
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: _navBar(),
      pane: NavigationPane(
        items: [
          ...createNavItems([Winget.updates, Winget.installed])
        ],
        footerItems: [
          ...createNavItems([Winget.about, Winget.help])
        ],
        selected: topIndex,
        onChanged: (index) {
          setState(() => topIndex = index);
        },
      ),
    );
  }

  List<PaneItem> createNavItems(List<Winget> commands) {
    return [for (Winget winget in commands) _navButton(winget)];
  }

  PaneItem _navButton(Winget winget) {
    Content content = Content(command: winget.command);
    return PaneItem(
      title: Text(winget.name),
      icon: Icon(winget.icon),
      body: contentPlace,
      onTap: () {
        setState(
          () {
            contentPlace.content.showResultOfCommand(winget.command);
          },
        );
      },
    );
  }

  NavigationAppBar _navBar() {
    return NavigationAppBar(
        //backgroundColor: FluentTheme.of(context).acrylicBackgroundColor,
        leading: _reloadAppBarButton(icon: FluentIcons.back, goBack: true),
        title: Text(
          widget.title,
          style: FluentTheme.of(context).typography.bodyLarge,
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
                      child: _searchField(Winget.search)),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.symmetric(horizontal: 10),
                    child:
                        _reloadAppBarButton(icon: FluentIcons.update_restore),
                  )
                ],
              ),
            );
          },
        )

        //actions: CommandBarCard(
        //  child: CommandBar(
        //    crossAxisAlignment: CrossAxisAlignment.center,
        //    mainAxisAlignment: MainAxisAlignment.center,
        //    isCompact: false,
        //    //overflowBehavior: CommandBarOverflowBehavior.wrap,
        //    primaryItems: [
        //      _menuButton(
        //          text: "Updates",
        //          command: ['upgrade'],
        //          icon: FluentIcons.substitutions_in),
        //      _menuButton(
        //          text: "Installed",
        //          command: ['list'],
        //          icon: FluentIcons.library),
        //      _reloadButton(
        //          text: "Reload Page", icon: FluentIcons.update_restore),
        //      _reloadButton(
        //          text: "Go Back", icon: FluentIcons.back, goBack: true),
        //      _menuButton(
        //          text: "About Winget",
        //          command: ['--info'],
        //          icon: FluentIcons.info),
        //      _menuSearchField(
        //          text: "Search Package",
        //          command: ['search'],
        //          optionalParameters: ['--count', '250'],
        //          icon: FluentIcons.search),
        //      _menuSearchField(
        //          text: "Show Package",
        //          command: ['show'],
        //          icon: FluentIcons.search),
        //      _commandPrompt(
        //        text: "Execute Command",
        //      )
        //    ],
        //  ),
        //),
        );
  }

  TextBox _searchField(Winget winget) {
    TextEditingController controller = TextEditingController();
    return TextBox(
      controller: controller,
      onSubmitted: (input) {
        setState(
          () {
            contentPlace.content
                .showResultOfCommand([...winget.command, input, "-n", '200']);
            controller.clear();
          },
        );
      },
      prefix: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 5),
          child: Icon(winget.icon)),
      placeholder: winget.name,
    );
  }

  CommandBarButton _menuButton(
      {required String text, required List<String> command, IconData? icon}) {
    return CommandBarButton(
      icon: (icon != null) ? Icon(icon) : null,
      label: Text(text),
      onPressed: () {
        setState(
          () {
            contentPlace.content.showResultOfCommand(command);
          },
        );
      },
    );
  }

  IconButton _reloadAppBarButton(
      {required IconData icon, bool goBack = false}) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        setState(
          () {
            goBack
                ? contentPlace.content.goBack()
                : contentPlace.content.reload();
          },
        );
      },
    );
  }

  CommandBarButton _reloadButton(
      {required String text, IconData? icon, bool goBack = false}) {
    return CommandBarButton(
      icon: (icon != null) ? Icon(icon) : null,
      label: Text(text),
      onPressed: () {
        setState(
          () {
            goBack
                ? contentPlace.content.goBack()
                : contentPlace.content.reload();
          },
        );
      },
    );
  }

  CommandBarBuilderItem _menuSearchField({
    required String text,
    required List<String> command,
    List<String>? optionalParameters,
    IconData? icon,
  }) {
    return _wrapWidget(TextBox(
      prefix: Text(text),
      suffix: (icon != null) ? Icon(icon) : null,
      onSubmitted: (String string) {
        setState(
          () {
            List<String> fullCommand = [
              ...command,
              string,
              ...?optionalParameters
            ];
            contentPlace.content.showResultOfCommand(fullCommand);
          },
        );
      },
    ));
  }

  CommandBarBuilderItem _commandPrompt({required String text, IconData? icon}) {
    return _wrapWidget(
      TextBox(
        prefix: Text(text),
        suffix: (icon != null) ? Icon(icon) : null,
        onSubmitted: (String command) {
          setState(
            () {
              contentPlace.content.showResultOfCommand(command.split(' '));
            },
          );
        },
      ),
    );
  }

  CommandBarBuilderItem _wrapWidget(Widget widget) {
    return CommandBarBuilderItem(
        builder: (BuildContext context, CommandBarItemDisplayMode displayMode,
            Widget child) {
          return widget;
        },
        wrappedItem: CommandBarButton(onPressed: () {}));
  }

  static ContentPlace _getContentPlace(Content content) =>
      ContentPlace(content: content, child: content);
}
