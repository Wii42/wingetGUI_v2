import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/winget_commands.dart';

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
        mainPageState.setState(
          () {
            mainPageState.contentPlace.content.showResultOfCommand(
              [
                ...winget.command,
                input,
              ],
            );
            controller.clear();
            mainPageState.topIndex = null;
          },
        );
      },
      prefix: mainPageState.prefixIcon(winget.icon),
      placeholder: winget.name,
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
                ? mainPageState.contentPlace.content.goBack()
                : mainPageState.contentPlace.content.reload();
          },
        );
      },
    );
  }
}
