import 'package:fluent_ui/fluent_ui.dart';

class PackageLongInfo extends StatelessWidget {
  final Map<String, String> infos;
  const PackageLongInfo(this.infos, {super.key});
  @override
  Widget build(BuildContext context) {
    return Column(children: [_topWidget(context), Text(infos.toString())]);
  }

  Widget _topWidget(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: FluentTheme.of(context).cardColor),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(infos['Name']!,
                    style: FluentTheme.of(context).typography.display, softWrap: true,),
                Text(infos['ID']!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
