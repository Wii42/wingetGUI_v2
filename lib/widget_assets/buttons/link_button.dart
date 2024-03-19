import 'package:fluent_ui/fluent_ui.dart';
import 'abstract_link_button.dart';

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
