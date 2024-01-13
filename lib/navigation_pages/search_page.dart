import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/routes.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';

import '../main.dart';
import '../widget_assets/package_peek_list_view.dart';
import '../winget_db/db_table.dart';

class SearchPage extends StatelessWidget {
  SearchPage({super.key});

  final TextEditingController controller = TextEditingController();
  final DBTable dbTable = wingetDB.available;

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    String title = Routes.searchPage.title(locale);
    return PaneItemBody(
      title: title,
      customReload: () => dbTable.reloadFuture(locale),
      child: Column(
        children: [
          Center(
            child: //ConstrainedBox(
                //constraints: const BoxConstraints(maxWidth: 400),
                //child:
                Wrap(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 5,
              runSpacing: 5,
              children: [
                //Text(title),
                const SizedBox(
                  height: 10,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: TextFormBox(
                      controller: controller, onFieldSubmitted: search(context)),
                ),
                const SizedBox(
                  height: 20,
                ),
                FilledButton(
                    onPressed: () => {search(context)(controller.text)},
                    child: Text(Routes.search.title(locale)))
              ],
            ),
          ),
          //),
          Expanded(
            child: PackagePeekListView(
              dbTable: wingetDB.available,
              showIsInstalled: (package, _) =>
                  wingetDB.installed.idMap.containsKey(package.id!.value),
              showIsUpgradable: (package, _) => package.availableVersion != null,
              showOnlyWithSourceButton: false,
            ),
          ),
        ].withSpaceBetween(height: 5),
      ),
    );
  }

  void Function(String) search(BuildContext context) {
    NavigatorState navigator = Navigator.of(context);
    return (input) {
      navigator.pushNamed(Routes.search.route,
          arguments: RouteParameter(
              commandParameter: [input], titleAddon: "'$input'"));
    };
  }

  factory SearchPage.inRoute([RouteParameter? _]) => SearchPage();
}
