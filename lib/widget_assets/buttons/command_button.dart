import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/winget_process/output_page.dart';
import 'package:winget_gui/winget_process/winget_process.dart';

import 'abstract_button.dart';
import 'run_button.dart';

/// A button that runs a winget command and shows the output in a new page.
class CommandButton extends RunButton
    with TextButtonWithIconMixin, FilledButtonMixin, RunAndOutputMixin {
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

mixin RunAndOutputMixin on RunButton {
  @override
  void onPressed(BuildContext context) => runCommand(
        context: context,
        command: command,
        title: pageTitle,
      );

  String pageTitle(AppLocalizations locale);

  static void runCommand(
      {required BuildContext context,
      required List<String> command,
      String Function(AppLocalizations)? title}) {
    WingetProcess process = WingetProcess.fromCommand(command);
    Navigator.of(context).push(
      FluentPageRoute(
        builder: (_) => OutputPage(
          process: process,
          title: title,
        ),
      ),
    );
  }
}
