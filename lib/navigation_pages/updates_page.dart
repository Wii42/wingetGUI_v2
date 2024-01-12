import 'package:fluent_ui/fluent_ui.dart';

import '../main.dart';
import '../widget_assets/package_peek_list_view.dart';
import '../widget_assets/pane_item_body.dart';
import '../winget_commands.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  static Widget inRoute([dynamic parameters]) {
    return const UpdatesPage();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return PaneItemBody(
      title: Winget.updates.title(locale),
      child: PackagePeekListView(
          dbTable: wingetDB.updates,
          isInstalled: (_, __) => true,
          isUpgradable: (_, __) => true),
    );
  }
}
