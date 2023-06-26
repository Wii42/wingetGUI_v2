import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';

import '../../widget_assets/decorated_box_wrap.dart';
import '../../widget_assets/link_text.dart';

class ListWidget extends StatelessWidget {
  final String title;
  final Map<String, String> list;

  const ListWidget({super.key, required this.title, required this.list});

  @override
  Widget build(BuildContext context) {
    Typography typography = FluentTheme.of(context).typography;
    return DecoratedBoxWrap(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$title:', style: typography.bodyStrong),
            for (String key in list.keys)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinkText(
                    line: key,
                    style: typography.bodyStrong,
                  ),
                  if (list[key]!.isNotEmpty) LinkText(line: list[key]!)
                ],
              )
          ].withSpaceBetween(height: 15),
        ),
      ),
    );
  }
}
