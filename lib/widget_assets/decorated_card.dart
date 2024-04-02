import 'package:fluent_ui/fluent_ui.dart';

class DecoratedCard extends StatelessWidget {
  final Widget child;
  final double? padding;
  final bool solidColor;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final bool hasBorder;

  const DecoratedCard(
      {required this.child,
      super.key,
      this.padding,
      this.solidColor = false,
      this.borderRadius,
      this.border, this.hasBorder = true});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    Color cardColor = FluentTheme.of(context).cardColor;
    return DecoratedBox(
        decoration: BoxDecoration(
          border: hasBorder? border ??
              Border.fromBorderSide(
                BorderSide(
                  color:
                      theme.resources.controlStrokeColorSecondary,
                  width: 0.33,
                ),
              ): null,
          color: solidColor
              ? FluentTheme.of(context).inactiveBackgroundColor
              : cardColor,
          borderRadius: borderRadius ?? BorderRadius.circular(5),
        ),
        child: padding == null
            ? child
            : Padding(
                padding: EdgeInsets.all(padding!),
                child: child,
              ));
  }
}
