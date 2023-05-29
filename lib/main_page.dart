import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/nav_bar.dart';
import 'package:winget_gui/winget_commands.dart';

import 'content/content.dart';
import 'content/content_place.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  ContentPlace contentPlace = _getContentPlace(Content());
  int? topIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavBar(mainPageState: this, context: context).build(),
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
      prefix: prefixIcon(FluentIcons.command_prompt),
      placeholder: 'Run command',
    );
  }

  Widget prefixIcon(IconData? icon) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 5),
      child: Icon(icon),
    );
  }

  static ContentPlace _getContentPlace(Content content) =>
      ContentPlace(content: content, child: content);
}
