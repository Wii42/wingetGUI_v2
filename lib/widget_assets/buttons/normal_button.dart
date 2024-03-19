import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/buttons/abstract_button.dart';

abstract class NormalButton extends AbstractButton {
  const NormalButton({super.key, super.disabled = false});

  @override
  Widget buildButton(BuildContext context) {
    return buttonType(child: child, onPressed: disabledOr(onPressed, context));
  }

  /// What happens when the button is pressed.
  void onPressed(BuildContext context);
}
