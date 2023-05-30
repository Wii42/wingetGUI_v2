import 'package:fluent_ui/fluent_ui.dart';

class DecoratedBoxWrap extends StatelessWidget {
  final Widget child;

  const DecoratedBoxWrap({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: child);
  }
}
