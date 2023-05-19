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
    return FilledButton(
        onPressed: () {
          ContentPlace.maybeOf(context)?.content.showResultOfCommand(command);
        },
        child: Text(text));
  }

}