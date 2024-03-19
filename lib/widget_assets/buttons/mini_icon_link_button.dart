import 'package:fluent_ui/fluent_ui.dart';

import 'abstract_link_button.dart';

class MiniIconLinkButton extends AbstractLinkButton {
  final IconData icon;
  const MiniIconLinkButton(
      {super.key,
      required super.url,
      this.icon = FluentIcons.open_in_new_window});

  @override
  BaseButton buttonType(
      {required Widget child, required VoidCallback? onPressed}) {
    return IconButton(
        icon: child,
        onPressed: onPressed,
        style: ButtonStyle(
          padding: ButtonState.all(
              const EdgeInsets.symmetric(vertical: 0, horizontal: 10)),
        ));
  }

  @override
  Widget get child => Icon(icon);
}
