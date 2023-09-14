import 'package:fluent_ui/fluent_ui.dart';

class DecoratedCard extends StatelessWidget {
  final Widget child;

  const DecoratedCard({required this.child, super.key});

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
        child: child);
  }
}
