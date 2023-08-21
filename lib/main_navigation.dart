import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'content/content_holder.dart';
import 'content/content_pane.dart';
import 'history_tab.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, required this.title, required this.child});
  final Widget child;
  final String title;

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int? topIndex;

  @override
  Widget build(BuildContext context) {

    return NavigationView(
      appBar: navBar(),
      pane: NavigationPane(
        autoSuggestBox: _commandPrompt(),
        autoSuggestBoxReplacement: const Icon(FluentIcons.command_prompt),
        items: [
          ...createNavItems([Winget.updates, Winget.installed], context),
          //HistoryTab(contentHolder!, local),
        ],
        footerItems: [
          ...createNavItems(
            [Winget.about, Winget.help, Winget.sources, Winget.settings],
            context,
          )
        ],
        selected: topIndex,
        onChanged: (index) {
          setState(() => topIndex = index);
        },
      ),
    );
  }

  List<PaneItem> createNavItems(List<Winget> commands, BuildContext context) {
    return [for (Winget winget in commands) _navButton(winget, context)];
  }

  PaneItem _navButton(Winget winget, BuildContext context) {
    AppLocalizations local = AppLocalizations.of(context)!;
    return PaneItem(
      title: Text(winget.title(local)),
      icon: Icon(winget.icon),
      body: widget.child,
      onTap: () => context.go(winget.route),
    );
  }

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
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.symmetric(horizontal: 10),
                  child: _reloadAppBarButton(icon: FluentIcons.update_restore),
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

  IconButton _reloadAppBarButton(
      {required IconData icon, bool goBack = false}) {
    return IconButton(
      icon: Icon(icon), onPressed: () {},
      //onPressed: () {
      //  setState(
      //    () {
      //      goBack
      //          ? contentHolder!.content.goBack()
      //          : contentHolder!.content.reload();
      //    },
      //  );
      //},
    );
  }
}
