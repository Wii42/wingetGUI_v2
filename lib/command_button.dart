import 'package:fluent_ui/fluent_ui.dart';

import 'content_place.dart';

class CommandButton extends StatelessWidget {
  const CommandButton({
    super.key,
    required this.text,
    required this.command,
  });

  final String text;
  final List<String> command;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message(command),
      useMousePosition: false,
      style: const TooltipThemeData(preferBelow: true),
      child: FilledButton(
        onPressed: () {
          ContentPlace.maybeOf(context)?.content.showResultOfCommand(command);
        },
        child: Text(text),
      ),
    );
  }

  static String message(List<String> command){
  return 'Execute command "winget ${command.join(" ")}"';
  }
}
