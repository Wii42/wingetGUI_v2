import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/widget_assets/run_button_tooltip.dart';

import '../winget_process/output_page.dart';
import '../winget_process/winget_process.dart';

abstract class RunButton extends StatelessWidget {
  final String text;
  final List<String> command;
  final String? title;
  final IconData? icon;
  final bool disabled;

  const RunButton({
    super.key,
    required this.text,
    required this.command,
    this.title,
    this.icon,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return RunButtonTooltip(
      button: buttonType(context),
      command: command,
    );
  }

  BaseButton buttonType(BuildContext context);

  void Function()? onPressed(BuildContext context) => disabled? null : () {
        NavigatorState router = Navigator.of(context);
        WingetProcess process = WingetProcess.fromCommand(command);
        router.push(FluentPageRoute(
            builder: (_) => OutputPage(
                  process: process,
                  title: title ?? "'$text'",
                )));
      };

  Widget child() => icon != null
      ? Row(
          children: [
            Icon(icon),
            Text(text),
          ].withSpaceBetween(width: 10),
        )
      : Text(text);
}
