import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/run_button_tooltip.dart';

import '../content/output_pane.dart';
import '../winget_process.dart';

abstract class RunButton extends StatelessWidget {
  const RunButton({
    super.key,
    required this.text,
    required this.command,
    this.title,
  });

  final String text;
  final List<String> command;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return RunButtonTooltip(
      button: buttonType(context),
      command: command,
    );
  }

  BaseButton buttonType(BuildContext context);

  void Function() onPressed(BuildContext context) => () async {
        NavigatorState router = Navigator.of(context);
        WingetProcess process = await WingetProcess.runCommand(command);
        router.push(FluentPageRoute(
            builder: (_) => OutputPane(
                  process: process,
                  title: title ?? "'$text'",
                )));
      };

  Widget child() => Text(text);
}
