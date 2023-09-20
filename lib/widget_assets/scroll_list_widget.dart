import 'package:fluent_ui/fluent_ui.dart';

import '../output_handling/output_builder.dart';

class ScrollListWidget extends StatelessWidget {
  final List<Widget>? listElements;
  final Stream<List<OutputBuilder>>? outputBuilders;
  final String? title;
  ScrollListWidget(
      {super.key, this.listElements, this.outputBuilders, this.title}) {
    assert((listElements != null) ^ (outputBuilders != null));
  }

  @override
  Widget build(BuildContext context) {
    return
        //ConstrainedBox(
        //constraints: const BoxConstraints(maxWidth: 1200),
        //child:
        Column(
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
    if (listElements != null) {
      return SingleChildScrollView(
        physics: physics,
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: listElements!,
        ),
      );
    }
    return StreamBuilder(
        stream: outputBuilders,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<OutputBuilder> data = snapshot.data!;
            return Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: data[index].getWidget(context),
                ),
                itemCount: data.length,
                physics: physics,
                padding: padding,
              ),
            );
          }
          return const Text('no data');
        });
  }
}
