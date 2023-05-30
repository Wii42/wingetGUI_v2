import 'package:fluent_ui/fluent_ui.dart';

import '../content/content_holder.dart';

class CommandButton extends StatelessWidget {
  const CommandButton({
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
    return Tooltip(
      message: message(command),
      useMousePosition: false,
      style: const TooltipThemeData(preferBelow: true),
      child: FilledButton(
        onPressed: () {
          ContentHolder.maybeOf(context)
              ?.content
              .showResultOfCommand(command, title: title ?? text);
        },
        child: Text(text),
      ),
    );
  }

  static String message(List<String> command) {
    return 'Run command "winget ${command.join(" ")}"';
  }
}
