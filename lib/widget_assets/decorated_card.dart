import 'package:fluent_ui/fluent_ui.dart';

class DecoratedCard extends StatelessWidget {
  final Widget child;
  final double? padding;

  const DecoratedCard({required this.child, super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
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
          color: FluentTheme.of(context).cardColor,
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
