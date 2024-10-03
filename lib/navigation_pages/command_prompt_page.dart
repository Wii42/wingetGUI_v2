import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/routes.dart';
import 'package:winget_gui/widget_assets/buttons/command_button.dart';
import 'package:winget_gui/widget_assets/buttons/page_button.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:winget_gui/winget_process/simple_output.dart';

class CommandPromptPage extends StatelessWidget {
  const CommandPromptPage({super.key});

  factory CommandPromptPage.inRoute([RouteParameter? _]) =>
      const CommandPromptPage();

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    String title = Routes.commandPromptPage.title(locale);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: PaneItemBody(
        title: title,
        child: LayoutBuilder(builder: (context, constraints) {
          return Center(
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
                  CommandPromptField(title: title),
                  const SizedBox(
                    height: 40,
                  ),
                  expandingHelpWindow(locale, constraints.maxHeight - 250)
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Expander expandingHelpWindow(AppLocalizations locale, double maxHeight) {
    return Expander(
      header: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20,
        runSpacing: 10,
        children: [
          Text(Routes.help.title(locale)),
          PageButton(
            pageRoute: Routes.help,
            buttonText: locale.showInSeparatePage,
            tooltipMessage: (locale) => locale.openHelpTooltip,
          )
        ],
      ),
      content: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: max(maxHeight, 0), maxWidth: 500),
          child: SimpleOutput.fromWinget(Winget.help)),
    );
  }
}

class CommandPromptField extends StatefulWidget {
  final String title;

  const CommandPromptField({super.key, required this.title});

  @override
  State<CommandPromptField> createState() => _CommandPromptFieldState();
}

class _CommandPromptFieldState extends State<CommandPromptField> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    String outputPageTitle(String input) => "${locale.runCommand} '$input'";
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        TextFormBox(
          controller: controller,
          onFieldSubmitted: (input) => RunAndOutputMixin.runCommand(
              context: context,
              command: input.split(' '),
              title: (locale) => outputPageTitle(input)),
        ),
        const SizedBox(
          height: 20,
        ),
        CommandButton(
            command: controller.text.split(' '),
            buttonText: widget.title,
            title: outputPageTitle(controller.text)),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
