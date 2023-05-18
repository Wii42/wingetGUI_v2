import 'package:fluent_ui/fluent_ui.dart';

import '../../content.dart';
import '../../content_place.dart';

class PackageShortInfo extends StatelessWidget {
  final Map<String, String> infos;
  const PackageShortInfo(this.infos, {super.key});

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: (_hasEntry('Quelle'))
          ? () {
              Content? target = ContentPlace.maybeOf(context)?.content;
              if (target != null && infos.containsKey('ID')) {
                target.showResultOfCommand(['show', '--id', infos['ID']!]);
              }
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  infos['Name']!,
                  style: _titleStyle(context)
                ),
                Text(infos['ID']!),
                if (_hasEntry('Quelle'))
                  Text(
                    "from ${infos['Quelle']!}",
                    style:
                        TextStyle(color: FluentTheme.of(context).disabledColor),
                  )
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_hasEntry('Version')) Text("Version: ${infos['Version']!}"),
                if (_hasEntry('Verfügbar'))
                  Text("Verfügbar: ${infos['Verfügbar']!}")
              ],
            ),
          ],
        ),
      ),
    );
    //return ;
  }

  TextStyle? _titleStyle(BuildContext context) {
    TextStyle? style = FluentTheme.of(context).typography.title;
    if (!_hasEntry('Quelle')) {
      style = style?.apply(color: FluentTheme.of(context).disabledColor);
    }
    return style;
  }

  bool _hasEntry(String key) {
    return (infos.containsKey(key) && infos[key]!.isNotEmpty);
  }
}
