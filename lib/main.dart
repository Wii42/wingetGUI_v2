import 'package:fluent_ui/fluent_ui.dart';
//import 'package:system_theme/system_theme.dart';
import 'package:winget_gui/content.dart';

import 'content_place.dart';

Future<void> main() async {
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
          brightness: Brightness.light),
      darkTheme: FluentThemeData(
        //accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: "Stream Test"),
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
  Content content = Content();

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        backgroundColor: FluentTheme.of(context).acrylicBackgroundColor,
        title: Text(widget.title),
        actions: CommandBarCard(
          child: CommandBar(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            //overflowBehavior: CommandBarOverflowBehavior.wrap,
            primaryItems: [
              _menuButton(
                  text: "Updates",
                  command: ['upgrade'],
                  icon: FluentIcons.substitutions_in),
              _menuButton(
                  text: "Installed",
                  command: ['list'],
                  icon: FluentIcons.library),
              _reloadButton(
                  text: "Reload Page", icon: FluentIcons.update_restore),
              _reloadButton(
                  text: "Go Back", icon: FluentIcons.back, goBack: true),
              _menuSearchField(
                  text: "Search Package",
                  command: ['search'],
                  optionalParameters: ['--count', '250'],
                  icon: FluentIcons.search),
              _menuSearchField(
                  text: "Show Package",
                  command: ['show'],
                  icon: FluentIcons.search),
              _commandPrompt(
                text: "Execute Command",
              )
            ],
          ),
        ),
      ),
      content: ContentPlace(content: content, child: content),
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
            content.showResultOfCommand(command);
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
            goBack ? content.goBack() : content.reload();
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
            content.showResultOfCommand(fullCommand);
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
              content.showResultOfCommand(command.split(' '));
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
}
