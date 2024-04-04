import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef LocalizedString = String Function(AppLocalizations);

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
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Tooltip(
      message: message(locale),
      useMousePosition: useMousePosition,
      style: const TooltipThemeData(preferBelow: true),
      child: button,
    );
  }

  LocalizedString get message;
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
  LocalizedString get message =>
      (locale) => locale.runCommandTooltip('winget ${command.join(' ')}');
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
  LocalizedString get message => (_) => url.toString();
}

class CustomTooltip extends ButtonTooltip {
  @override
  final LocalizedString message;

  const CustomTooltip({
    super.key,
    required this.message,
    required super.button,
    super.useMousePosition = false,
  });
}
