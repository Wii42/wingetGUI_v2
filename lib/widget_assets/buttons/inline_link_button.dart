import 'package:fluent_ui/fluent_ui.dart';

import 'abstract_link_button.dart';

class InlineLinkButton extends AbstractLinkButton {
  final Text text;
  const InlineLinkButton({super.key, required super.url, required this.text});

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
