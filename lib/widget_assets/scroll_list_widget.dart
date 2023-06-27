import 'package:fluent_ui/fluent_ui.dart';

class ScrollListWidget extends StatelessWidget {
  final List<Widget> listElements;
  final String? title;
  const ScrollListWidget({super.key, required this.listElements, this.title});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                title!,
                style: FluentTheme.of(context).typography.title,
              ),
            ),
          Expanded(
            child: Center(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(10),
                shrinkWrap: true,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: listElements,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
