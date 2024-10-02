import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart'
    as system_icons;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/routes.dart';

import 'buttons/page_button.dart';
import 'pane_item_body.dart';

class PaneItemExpanderBody extends StatelessWidget {
  final List<Routes> children;
  final String title;
  final IconData? icon;
  const PaneItemExpanderBody({
    super.key,
    required this.children,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PaneItemBody(
        title: title,
        icon: icon,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                for (Routes child in children) linkToChild(child, context)
              ],
            ),
          ),
        ));
  }

  Widget linkToChild(Routes child, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return PageButtonWithIcon(
        pageRoute: child,
        buttonText: child.title(locale),
        icon: child.icon ?? system_icons.FluentIcons.question_circle_24_regular,
        tooltipMessage: (locale) => child.title(locale));
  }
}
