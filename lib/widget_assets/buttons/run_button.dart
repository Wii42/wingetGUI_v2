import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/widget_assets/buttons/tooltips.dart';

import 'abstract_button.dart';

/// A button that runs a command when pressed.
/// The concrete behaviour and appearance needs to be implemented by the subclasses, for example with the provided mixins.
abstract class RunButton extends AbstractButton {
  /// The command to be run when the button is pressed. Needed for the tooltip.
  final List<String> command;
  const RunButton({
    super.key,
    required this.command,
    super.disabled = false,
  });

  @override
  RunButtonTooltip buildTooltip(BuildContext context, {required Widget child}) {
    return RunButtonTooltip(
      button: child,
      command: command,
    );
  }

  @override
  Widget buildButton(BuildContext context) {
    return buttonType(child: child, onPressed: _disabledOr(onPressed, context));
  }

  /// If the button is disabled, it returns null, otherwise it returns the onPressed function.
  void Function()? _disabledOr(
          void Function(BuildContext) onPressed, BuildContext context) =>
      disabled ? null : () => onPressed(context);

  /// What happens when the button is pressed.
  void onPressed(BuildContext context);
}
