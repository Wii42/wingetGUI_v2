import 'package:fluent_ui/fluent_ui.dart';

class RunButtonTooltip extends StatelessWidget {
  final List<String> command;
  final BaseButton button;
  final bool useMousePosition;

  const RunButtonTooltip({
    super.key,
    required this.command,
    required this.button,
    this.useMousePosition = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message(command),
      useMousePosition: useMousePosition,
      style: const TooltipThemeData(preferBelow: true),
      child: button,
    );
  }

  static String message(List<String> command) {
    return 'Run command "winget ${command.join(" ")}"';
  }
}
