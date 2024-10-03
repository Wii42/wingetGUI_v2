import 'package:fluent_ui/fluent_ui.dart';

import 'abstract_button.dart';
import 'abstract_link_button.dart';

class MiniIconLinkButton extends AbstractLinkButton with MiniIconButton {
  @override
  final IconData icon;

  const MiniIconLinkButton(
      {super.key,
      required super.url,
      this.icon = FluentIcons.open_in_new_window});
}

mixin MiniIconButton on AbstractButton {
  @override
  BaseButton buttonType(
      {required Widget child, required VoidCallback? onPressed}) {
    return IconButton(
        icon: child,
        onPressed: onPressed,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 0, horizontal: 10)),
        ));
  }

  @override
  Widget get child => Icon(icon);

  IconData get icon;
}
