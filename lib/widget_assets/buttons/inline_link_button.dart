import 'package:fluent_ui/fluent_ui.dart';

import 'abstract_button.dart';
import 'abstract_link_button.dart';

class InlineLinkButton extends AbstractLinkButton
    with TextButtonMixin, InlineLinkButtonMixin {
  @override
  final String buttonText;
  const InlineLinkButton(
      {super.key, required super.url, required this.buttonText});
}

mixin InlineLinkButtonMixin on AbstractButton {
  @override
  BaseButton buttonType(
      {required Widget child, required VoidCallback? onPressed}) {
    return HyperlinkButton(
      style: ButtonStyle(
        padding: ButtonState.all(EdgeInsets.zero),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
