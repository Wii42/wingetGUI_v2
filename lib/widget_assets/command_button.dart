import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/widget_assets/run_button.dart';

class CommandButton extends RunButton
    with TextButtonMixin, FilledButtonMixin, RunAndOutputMixin {
  @override
  final String buttonText;
  @override
  final IconData? icon;
  final String? title;
  const CommandButton(
      {super.key,
      required super.command,
      super.disabled,
      required this.buttonText,
      this.icon,
      this.title});

  @override
  String pageTitle(AppLocalizations locale) => title ?? "'$buttonText'";
}

class CommandIconButton extends RunButton
    with IconButtonMixin, RunAndOutputMixin {
  @override
  final EdgeInsetsGeometry padding;
  @override
  final IconData icon;
  final String title;
  const CommandIconButton(
      {super.key,
      required super.command,
      required this.title,
      required this.icon,
      this.padding = EdgeInsets.zero,
      super.disabled});

  @override
  String pageTitle(AppLocalizations locale) => title;
}
