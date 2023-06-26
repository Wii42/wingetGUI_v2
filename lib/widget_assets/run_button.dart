import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/run_button_tooltip.dart';

import '../content/content_holder.dart';

abstract class RunButton extends StatelessWidget {
  const RunButton({
    super.key,
    required this.text,
    required this.command,
    this.title,
    this.contentHolder,
  });

  final String text;
  final List<String> command;
  final String? title;
  final ContentHolder? contentHolder;

  @override
  Widget build(BuildContext context) {
    return RunButtonTooltip(
      button: buttonType(context),
      command: command,
    );
  }

  BaseButton buttonType(BuildContext context);

  void Function() onPressed(BuildContext context) => () {
        ContentHolder? holder = contentHolder ?? ContentHolder.maybeOf(context);
        holder?.content.showResultOfCommand(command, title: title ?? "'$text'");
      };

  Widget child() => Text(text);
}