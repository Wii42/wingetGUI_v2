import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/routes.dart';

import 'pane_item_body.dart';

class PaneItemExpanderBody extends StatelessWidget {
  final List<Routes> children;
  final String title;
  const PaneItemExpanderBody({
    super.key,
    required this.children,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return PaneItemBody(
        title: title,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                for (Routes child in children) linkToChild(child, context)
              ],
            ),
          ),
        ));
  }

  Widget linkToChild(Routes child, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    NavigatorState navigator = Navigator.of(context);
    return FilledButton(
        onPressed: () {
          navigator.pushNamed(child.route);
        },
        child: Text(child.title(locale)));
  }
}
