import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/abstract_link_button.dart';

class LinkButton extends AbstractLinkButton {
  final Text text;

  const LinkButton({super.key, required super.url, required this.text});

  @override
  BaseButton button(BuildContext context, Future<void> Function()? open) {
    return Button(
      onPressed: open,
      child: text,
    );
  }
}
