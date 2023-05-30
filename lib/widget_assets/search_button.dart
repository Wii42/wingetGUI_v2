import 'package:fluent_ui/fluent_ui.dart';

import '../content/content_holder.dart';
import 'command_button.dart';

class SearchButton extends StatelessWidget {
  late final List<String> command;

  final String searchTarget;

  SearchButton({super.key, required this.searchTarget}) {
    command = ['search', searchTarget];
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: CommandButton.message(command),
        useMousePosition: false,
        style: const TooltipThemeData(preferBelow: true),
        child: Button(
            onPressed: () {
              ContentHolder.maybeOf(context)
                  ?.content
                  .showResultOfCommand(command);
            },
            child: Text(searchTarget)));
  }
}
