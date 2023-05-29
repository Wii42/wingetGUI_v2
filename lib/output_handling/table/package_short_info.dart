import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/output_handling/right_side_buttons.dart';

import '../../content/content.dart';
import '../../content/content_place.dart';
import '../info_enum.dart';

class PackageShortInfo extends StatelessWidget {
  final Map<String, String> infos;

  const PackageShortInfo(this.infos, {super.key});

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: (isClickable())
          ? () {
              Content? target = ContentPlace.maybeOf(context)?.content;
              if (target != null && infos.containsKey(Info.id.key)) {
                target
                    .showResultOfCommand(['show', '--id', infos[Info.id.key]!]);
              }
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    infos[Info.name.key]!,
                    style: _titleStyle(context),
                    softWrap: true,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(
                    infos[Info.id.key]!,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  if (infos.hasEntry(Info.source.key))
                    Text(
                      "from ${infos[Info.source.key]!}",
                      style: TextStyle(
                        color: FluentTheme.of(context).disabledColor,
                      ),
                      textAlign: TextAlign.start,
                    )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _versions([Info.version, Info.availableVersion]),
            ),
            if (isClickable()) const SizedBox(width: 20),
            if (isClickable()) RightSideButtons(infos: infos),
          ],
        ),
      ),
    );
    //return ;
  }

  TextStyle? _titleStyle(BuildContext context) {
    TextStyle? style = FluentTheme.of(context).typography.title;
    if (!isClickable()) {
      style = style?.apply(color: FluentTheme.of(context).disabledColor);
    }
    return style;
  }

  List<Widget> _versions(List<Info> versions) {
    return [
      for (Info info in versions)
        if (infos.hasEntry(info.key))
          Text("${info.title}: ${infos[info.key]!}"),
    ];
  }

  bool isClickable() {
    return infos.hasEntry(Info.source.key);
  }
}
