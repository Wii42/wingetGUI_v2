import 'package:fluent_ui/fluent_ui.dart';

class ScrollListWidget extends StatelessWidget {
  final List<Widget> listElements;
  final String? title;

  const ScrollListWidget({super.key, required this.listElements, this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: view(),
        ),
        //)
      ],
      //),
    );
  }

  Widget view() {
    ScrollPhysics physics = const BouncingScrollPhysics();
    EdgeInsetsGeometry padding = const EdgeInsets.all(10);

    return SingleChildScrollView(
      physics: physics,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: listElements,
      ),
    );
  }
}
