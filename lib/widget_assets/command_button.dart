import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/run_button.dart';

import '../content/content_holder.dart';

class CommandButton extends RunButton {
  const CommandButton(
      {super.key, required super.text, required super.command, super.title});

  @override
  BaseButton buttonType(BuildContext context) =>
      FilledButton(onPressed: onPressed(context), child: child());
}
