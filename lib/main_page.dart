import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/nav_bar.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'content/content_holder.dart';
import 'content/content_pane.dart';
import 'history_tab.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  ContentHolder? contentHolder;
  int? topIndex;

  @override
  Widget build(BuildContext context) {
    AppLocalizations local = AppLocalizations.of(context)!;
    contentHolder ??= _getContentHolder(ContentPane(
      local: local,
    ));
    return NavigationView(
      appBar: NavBar(mainPageState: this, context: context).build(),
      pane: NavigationPane(
        autoSuggestBox: _commandPrompt(),
        autoSuggestBoxReplacement: const Icon(FluentIcons.command_prompt),
        items: [
          ...createNavItems([Winget.updates, Winget.installed], local),
          HistoryTab(contentHolder!, local),
        ],
        footerItems: [
          ...createNavItems(
            [Winget.about, Winget.sources, Winget.help, Winget.settings],
            local,
          )
        ],
        selected: topIndex,
        onChanged: (index) {
          setState(() => topIndex = index);
        },
      ),
    );
  }

  List<PaneItem> createNavItems(List<Winget> commands, AppLocalizations local) {
    return [for (Winget winget in commands) _navButton(winget, local)];
  }

  PaneItem _navButton(Winget winget, AppLocalizations local) {
    return PaneItem(
      title: Text(winget.name(local)),
      icon: Icon(winget.icon),
      body: contentHolder!,
      onTap: () {
        setState(
          () {
            contentHolder!.content
                .showResultOfCommand(winget.command, title: winget.name(local));
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
            contentHolder!.content.showResultOfCommand(command.split(' '));
            controller.clear();
            topIndex = null;
          },
        );
      },
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

  static ContentHolder _getContentHolder(ContentPane content) =>
      ContentHolder(content: content, child: content);
}
