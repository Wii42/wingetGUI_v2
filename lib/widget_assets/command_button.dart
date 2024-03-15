import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/run_button.dart';

class CommandButton extends RunButton {
  const CommandButton(
      {super.key,
      required super.text,
      required super.command,
      super.title,
      super.icon,
      super.disabled});

  @override
  BaseButton buttonType(BuildContext context) =>
      FilledButton(onPressed: onPressed(context), child: child());
}

class CommandIconButton extends RunButton {
  final EdgeInsetsGeometry padding;
  const CommandIconButton(
      {super.key,
      required super.text,
      required super.command,
      super.title,
      required IconData icon,
      this.padding = EdgeInsets.zero,
      super.disabled})
      : super(icon: icon);

  @override
  BaseButton buttonType(BuildContext context) => IconButton(
      icon: Padding(
        padding: padding,
        child: Icon(icon),
      ),
      onPressed: onPressed(context));
}
