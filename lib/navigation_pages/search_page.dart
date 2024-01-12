import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/routes.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';

import '../main.dart';
import '../widget_assets/package_peek_list_view.dart';
import '../winget_db/winget_db.dart';

class SearchPage extends StatelessWidget {
  SearchPage({super.key});

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    String title = Routes.searchPage.title(locale);
    return PaneItemBody(
      title: title,
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormBox(
                        controller: controller,
                        onFieldSubmitted: search(context)),
                    const SizedBox(
                      height: 20,
                    ),
                    FilledButton(
                        onPressed: () => {search(context)(controller.text)},
                        child: Text(Routes.search.title(locale)))
                  ],
                )),
          ),
          Expanded(
            child: Consumer<WingetDB>(
              builder: (BuildContext context, WingetDB wingetDB, Widget? _) {
                return PackagePeekListView(
                  dbTable: wingetDB.available,
                  isInstalled: (package, _) =>
                      wingetDB.installed.idMap.containsKey(package.id!.value),
                  isUpgradable: (package, _) =>
                      package.availableVersion != null,
                );
              },
            ),
          ),
        ],
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
