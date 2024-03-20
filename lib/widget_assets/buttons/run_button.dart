import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/buttons/tooltips.dart';

import 'normal_button.dart';

/// A button that runs a command when pressed.
/// The concrete behaviour and appearance needs to be implemented by the subclasses, for example with the provided mixins.
abstract class RunButton extends NormalButton {
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
}
