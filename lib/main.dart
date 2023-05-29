import 'package:fluent_ui/fluent_ui.dart';
// 'package:system_theme/system_theme.dart';
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
      title: 'WingetGUI',
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

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: _navBar(),
      pane: NavigationPane(
        autoSuggestBox: _commandPrompt(),
        autoSuggestBoxReplacement: const Icon(FluentIcons.command_prompt),
        items: [
          ...createNavItems([Winget.updates, Winget.installed])
        ],
        footerItems: [
          ...createNavItems(
              [Winget.about, Winget.sources, Winget.help, Winget.settings])
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
        ));
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
            topIndex = null;
          },
        );
      },
      prefix: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 5),
          child: Icon(winget.icon)),
      placeholder: winget.name,
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

  TextBox _commandPrompt() {
    TextEditingController controller = TextEditingController();
    return TextBox(
      controller: controller,
      onSubmitted: (String command) {
        setState(
          () {
            contentPlace.content.showResultOfCommand(command.split(' '));
            controller.clear();
            topIndex = null;
          },
        );
      },
      prefix: const Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 5),
          child: Icon(FluentIcons.command_prompt)),
      placeholder: 'Run command',
    );
  }

  static ContentPlace _getContentPlace(Content content) =>
      ContentPlace(content: content, child: content);
}
