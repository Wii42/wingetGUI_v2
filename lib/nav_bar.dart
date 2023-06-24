import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'main_page.dart';

class NavBar {
  MainPageState mainPageState;
  BuildContext context;

  NavBar({required this.mainPageState, required this.context});

  NavigationAppBar build() {
    return NavigationAppBar(
        leading: _reloadAppBarButton(icon: FluentIcons.back, goBack: true),
        title: Text(
          mainPageState.widget.title,
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
                    child:
                        _reloadAppBarButton(icon: FluentIcons.update_restore),
                  )
                ],
              ),
            );
          },
        ));
  }

  TextBox _searchField(Winget winget, AppLocalizations local) {
    TextEditingController controller = TextEditingController();
    return TextBox(
      controller: controller,
      onSubmitted: (input) {
        mainPageState.setState(
          () {
            mainPageState.contentHolder!.content.showResultOfCommand(
              [
                ...winget.command,
                input,
              ],
              title: winget.titleWithInput(input, localization: local),
            );
            controller.clear();
            mainPageState.topIndex = null;
          },
        );
      },
      prefix: mainPageState.prefixIcon(winget.icon),
      placeholder: winget.title(local),
    );
  }

  IconButton _reloadAppBarButton(
      {required IconData icon, bool goBack = false}) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        mainPageState.setState(
          () {
            goBack
                ? mainPageState.contentHolder!.content.goBack()
                : mainPageState.contentHolder!.content.reload();
          },
        );
      },
    );
  }
}
