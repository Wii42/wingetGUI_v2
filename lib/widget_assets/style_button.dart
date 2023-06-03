import 'package:fluent_ui/fluent_ui.dart';

class StyleButton extends StatelessWidget {
  final Widget child;
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final void Function()? onTapDown;
  final void Function()? onTapUp;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool focusable;

  const StyleButton(
      {super.key,
      required this.child,
      required this.onPressed,
      this.onLongPress,
      this.onTapDown,
      this.onTapUp,
      this.focusNode,
      this.autofocus = false,
      this.focusable = true});

  @override
  build(BuildContext context) {
    return HyperlinkButton(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      focusNode: focusNode,
      autofocus: autofocus,
      focusable: focusable,
      child: child,
    );
  }
}
