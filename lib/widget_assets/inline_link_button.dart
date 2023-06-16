import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/link_button.dart';

class InlineLinkButton extends LinkButton {
  const InlineLinkButton({super.key, required super.url, required super.text});

  @override
  BaseButton button(BuildContext context, Future<void> Function()? open) {
    return HyperlinkButton(
      style: ButtonStyle(
        padding: ButtonState.all(EdgeInsets.zero),
        //textStyle: ButtonState.all(FluentTheme.of(context).typography.body),
      ),
      onPressed: open,
      child: text,
    );
  }
}
