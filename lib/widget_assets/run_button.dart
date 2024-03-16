import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/widget_assets/run_button_tooltip.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../output_handling/package_infos/package_infos.dart';
import '../winget_process/output_page.dart';
import '../winget_process/package_action_type.dart';
import '../winget_process/winget_process.dart';

abstract class RunButton extends StatelessWidget {
  final List<String> command;
  final bool disabled;

  const RunButton({
    super.key,
    required this.command,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return RunButtonTooltip(
      button:
          buttonType(child: child, onPressed: _disabledOr(onPressed, context)),
      command: command,
    );
  }

  void Function()? _disabledOr(
          void Function(BuildContext) onPressed, BuildContext context) =>
      disabled ? null : () => onPressed(context);

  /// The button type to be used, e.g. Button, IconButton, FilledButton.
  /// [child] and [onPressed] should be passed to the button type, without changing them.
  BaseButton buttonType(
      {required Widget child, required VoidCallback? onPressed});

  /// What happens when the button is pressed.
  void onPressed(BuildContext context);

  /// The button's child widget, e.g. what is displayed on the button.
  Widget get child;
}

mixin TextButtonMixin on RunButton {
  String get buttonText;
  IconData? get icon;

  @override
  Widget get child => icon != null
      ? Row(
          children: [
            Icon(icon),
            Text(buttonText),
          ].withSpaceBetween(width: 10),
        )
      : Text(buttonText);
}

mixin IconButtonMixin on RunButton {
  IconData get icon;
  EdgeInsetsGeometry get padding;

  @override
  Widget get child => Padding(
        padding: padding,
        child: Icon(icon),
      );

  @override
  BaseButton buttonType(
      {required Widget child, required VoidCallback? onPressed}) {
    return IconButton(icon: child, onPressed: onPressed);
  }
}

mixin FilledButtonMixin on RunButton {
  @override
  BaseButton buttonType(
      {required Widget child, required VoidCallback? onPressed}) {
    return FilledButton(onPressed: onPressed, child: child);
  }
}
mixin RunAndOutputMixin on RunButton {
  @override
  void onPressed(BuildContext context) {
    NavigatorState router = Navigator.of(context);
    WingetProcess process = WingetProcess.fromCommand(command);
    router.push(FluentPageRoute(
        builder: (_) => OutputPage(
              process: process,
              title: pageTitle,
            )));
  }

  String pageTitle(AppLocalizations locale);
}

mixin RunPackageActionMixin on RunButton {
  PackageActionType get type;

  PackageInfos get infos;

  @override
  void onPressed(BuildContext context) => type.runAction(infos, context);
}
