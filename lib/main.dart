import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';
import 'package:winget_gui/content.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Flutter Demo',
      theme: FluentThemeData(
          accentColor: SystemTheme.accentColor.accent.toAccentColor(),
          brightness: Brightness.light),
      darkTheme: FluentThemeData(
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
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
                  text: "Reload Page",
                  icon: FluentIcons.update_restore),

              menuSearchField(
                  text: "Search Package",
                  command: ['search'],
                  icon: FluentIcons.search),
              menuSearchField(
                  text: "Show Package",
                  command: ['show'],
                  icon: FluentIcons.search),

            ],
          ),
        ),
      ),
      content: content,
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
      {required String text, IconData? icon}) {
    return CommandBarButton(
      icon: (icon != null) ? Icon(icon) : null,
      label: Text(text),
      onPressed: () {
        setState(
              () {
            content.reload();
          },
        );
      },
    );
  }

  CommandBarBuilderItem menuSearchField(
      {required String text, required List<String> command, IconData? icon}) {
    return CommandBarBuilderItem(
        builder: (BuildContext context, CommandBarItemDisplayMode displayMode,
            Widget child) {
          return TextBox(
            prefix: Text(text),
            suffix: (icon != null) ? Icon(icon) : null,
            onSubmitted: (String string) {
              setState(
                () {
                  List<String> fullCommand = [...command]..add(string);
                  content.showResultOfCommand(fullCommand);
                },
              );
            },
          );
        },
        wrappedItem: CommandBarButton(onPressed: () {}));
  }
}
