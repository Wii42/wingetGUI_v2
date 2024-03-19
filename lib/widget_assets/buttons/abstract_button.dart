import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/widget_assets/buttons/tooltips.dart';

abstract class AbstractButton extends StatelessWidget {
  final bool disabled;

  const AbstractButton({
    super.key,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return buildTooltip(
      context,
      child: buildButton(context),
    );
  }

  /// The button to be displayed. should only be overridden by the higher level classes.
  /// Should use [buttonType] to create the button and pass [child] and [disabledOr] idf possible.
  Widget buildButton(BuildContext context);

  /// The tooltip to be displayed when hovering over the button.
  ButtonTooltip buildTooltip(BuildContext context, {required Widget child});

  /// The button type to be used, e.g. Button, IconButton, FilledButton.
  /// [child] and [onPressed] should be passed to the button type, without changing them.
  BaseButton buttonType(
      {required Widget child, required VoidCallback? onPressed});

  /// The button's child widget, e.g. what is displayed on the button.
  Widget get child;

  /// If the button is disabled, it returns null, otherwise it returns the onPressed function.
  void Function()? disabledOr(
          void Function(BuildContext)? onPressed, BuildContext context) =>
      disabled || onPressed == null ? null : () => onPressed(context);
}

mixin TextButtonMixin on AbstractButton {
  String get buttonText;

  @override
  Widget get child => Text(buttonText);
}

mixin TextButtonWithIconMixin on AbstractButton {
  IconData? get icon;
  String get buttonText;

  @override
  Widget get child => icon != null
      ? Row(
          children: [
            Icon(icon),
            Text(buttonText),
          ].withSpaceBetween(width: 10),
        )
      : Text(buttonText);
}

mixin IconButtonMixin on AbstractButton {
  IconData get icon;
  EdgeInsetsGeometry get padding;

  @override
  Widget get child => Padding(
        padding: padding,
        child: Icon(icon),
      );

  @override
  BaseButton buttonType(
      {required Widget child, required VoidCallback? onPressed}) {
    return IconButton(icon: child, onPressed: onPressed);
  }
}

mixin FilledButtonMixin on AbstractButton {
  @override
  BaseButton buttonType(
      {required Widget child, required VoidCallback? onPressed}) {
    return FilledButton(onPressed: onPressed, child: child);
  }
}

mixin PlainButtonMixin on AbstractButton {
  @override
  BaseButton buttonType(
          {required Widget child, required VoidCallback? onPressed}) =>
      Button(onPressed: onPressed, child: child);
}

mixin CustomToolTipMixin on AbstractButton {
  String get tooltipMessage;

  @override
  ButtonTooltip buildTooltip(BuildContext context, {required Widget child}) {
    return CustomTooltip(
      message: tooltipMessage,
      button: child,
      useMousePosition: useMousePosition,
    );
  }

  bool get useMousePosition => false;
}
