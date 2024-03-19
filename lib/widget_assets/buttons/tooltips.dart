import 'package:fluent_ui/fluent_ui.dart';

abstract class ButtonTooltip extends StatelessWidget {
  final Widget button;
  final bool useMousePosition;

  const ButtonTooltip({
    super.key,
    required this.button,
    this.useMousePosition = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      useMousePosition: useMousePosition,
      style: const TooltipThemeData(preferBelow: true),
      child: button,
    );
  }

  String get message;
}

class RunButtonTooltip extends ButtonTooltip {
  final List<String> command;
  const RunButtonTooltip({
    super.key,
    required this.command,
    required super.button,
    super.useMousePosition = false,
  });

  @override
  String get message {
    return 'Run command "winget ${command.join(" ")}"';
  }
}

class LinkToolTip extends ButtonTooltip {
  final Uri url;

  const LinkToolTip({
    super.key,
    required this.url,
    required super.button,
    super.useMousePosition = false,
  });

  @override
  String get message => url.toString();
}
