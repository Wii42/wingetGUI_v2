import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/winget_process/simple_output_starter.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/routes.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:winget_gui/winget_process/winget_process.dart';

import '../winget_process/output_page.dart';


class CommandPromptPage extends StatelessWidget {
  CommandPromptPage({super.key});

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    String title = Routes.commandPromptPage.title(locale);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: PaneItemBody(
        title: title,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
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
                Expander(
                  header: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      Text(Routes.help.title(locale)),
                      Button(
                        onPressed: () {
                          NavigatorState navigator = Navigator.of(context);
                          navigator.pushNamed(Routes.help.route);
                        },
                        child: Text(locale.showInSeparatePage),
                      ),
                    ],
                  ),
                  content: SizedBox(
                      width: 500,
                      height: 500,
                      child: SimpleOutputStarter(command: Winget.help.fullCommand)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void Function(String) run(BuildContext context) {
    NavigatorState navigator = Navigator.of(context);
    AppLocalizations locale = AppLocalizations.of(context)!;
    return (input) async {
      WingetProcess process = await WingetProcess.runCommand(input.split(' '));
      navigator.push(FluentPageRoute(
          builder: (_) => OutputPage(
                process: process,
                title: "${locale.runCommand} '$input'",
              )));
    };
  }

  factory CommandPromptPage.inRoute([RouteParameter? _]) => CommandPromptPage();
}
