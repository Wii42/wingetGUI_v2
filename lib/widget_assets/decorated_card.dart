import 'package:fluent_ui/fluent_ui.dart';

class DecoratedCard extends StatelessWidget {
  final Widget child;
  final double? padding;
  final bool solidColor;

  const DecoratedCard(
      {required this.child, super.key, this.padding, this.solidColor = false});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    Color cardColor = FluentTheme.of(context).cardColor;
    return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.fromBorderSide(
            BorderSide(
              color:
                  //theme.resources.controlStrokeColorDefault,
                  theme.resources.controlStrokeColorSecondary,
              width: 0.33,
            ),
          ),
          color: solidColor
              ? FluentTheme.of(context).inactiveBackgroundColor
              : cardColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: padding == null
            ? child
            : Padding(
                padding: EdgeInsets.all(padding!),
                child: child,
              ));
  }
}
