import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';

import '../../widget_assets/decorated_card.dart';
import '../../widget_assets/link_text.dart';
import '../output_builder.dart';

class ListBuilder extends OutputBuilder {
  final String title;
  final Map<String, String> list;

  ListBuilder({ required this.title, required this.list});

  @override
  Widget build(BuildContext context) {
    Typography typography = FluentTheme.of(context).typography;
    return DecoratedCard(
      padding: 10,
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
    );
  }
}