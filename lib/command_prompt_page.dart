import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/routes.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';
import 'package:winget_gui/winget_process.dart';

import 'content/output_pane.dart';

class CommandPromptPage extends StatelessWidget {
  CommandPromptPage({super.key});

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    String title = Routes.commandPromptPage.title(locale);
    return PaneItemBody(
      title: title,
      child: Center(
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
                    controller: controller, onFieldSubmitted: run(context)),
                const SizedBox(
                  height: 20,
                ),
                FilledButton(
                    onPressed: () => {run(context)(controller.text)},
                    child: Text(title)),
                const SizedBox(
                  height: 40,
                ),
                Button(
                    onPressed: () {
                      NavigatorState navigator = Navigator.of(context);
                      navigator.pushNamed(Routes.help.route);
                    },
                    child: Text(Routes.help.title(locale)))
              ],
            )),
      ),
    );
  }

  void Function(String) run(BuildContext context) {
    NavigatorState navigator = Navigator.of(context);
    AppLocalizations locale = AppLocalizations.of(context)!;
    return (input) async {
      WingetProcess process = await WingetProcess.runCommand(input.split(' '));
      navigator.push(FluentPageRoute(
          builder: (_) => OutputPane(
                process: process,
                title: "${locale.runCommand} '$input'",
              )));
    };
  }

  factory CommandPromptPage.inRoute([RouteParameter? _]) => CommandPromptPage();
}
