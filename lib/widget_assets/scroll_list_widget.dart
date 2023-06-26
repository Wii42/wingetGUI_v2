import 'package:fluent_ui/fluent_ui.dart';

class ScrollListWidget extends StatelessWidget {
  final List<Widget> listElements;
  final String? title;
  const ScrollListWidget({super.key, required this.listElements, this.title});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(10),
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                title!,
                style: FluentTheme.of(context).typography.title,
              ),
            ),
          ...listElements
        ])
      ],
    );
  }
}
