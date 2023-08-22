import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/widget_assets/link_button.dart';

import '../../helpers/extensions/string_extension.dart';
import '../../widget_assets/link_text.dart';

const quotationMarks = [
  '«',
  '‹',
  '»',
  '›',
  '„',
  '“',
  '‟',
  '”',
  '’',
  '’',
  '❝',
  '❞',
  '❮',
  '❯',
  '⹂',
  '〝',
  '〞',
  '〟',
  '＂',
  '‚',
  '‘',
  '‛',
  '❛',
  '❜',
  '❟',
  '"',
  "'",
  '„',
  '“'
];

class OneLineInfoWidget extends StatelessWidget {
  final Map<String, String> infos;
  const OneLineInfoWidget({required this.infos, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 5),
      child: infoWidgets(context),
    );
  }

  Widget infoWidgets(BuildContext context) {
    if (infos.length == 1) {
      return oneLineInfo(infos.keys.single, context);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (String key in infos.keys) oneLineInfo(key, context)]
          .withSpaceBetween(height: 5),
    );
  }

  Widget oneLineInfo(String key, BuildContext context) {
    String value = stripOfQuotationMarks(infos[key]!);
    if (isLink(value)) {
      return LinkButton(url: value, text: Text(key));
    }
    return Wrap(
      spacing: 5,
      children: [
        Text('$key:', style: FluentTheme.of(context).typography.bodyStrong),
        LinkText(line: value)
      ],
    );
  }

  String stripOfQuotationMarks(String string) {
    string = string.trim();
    if (string.startsWith(quotationMarksRegExp()) &&
        string[string.length - 1].contains(quotationMarksRegExp()) &&
        !string
            .substring(1, string.length - 1)
            .contains(quotationMarksRegExp())) {
      string = string.substring(1, string.length - 1);
       if (kDebugMode) {
         print(string);
       }
    }
    return string;
  }

  RegExp quotationMarksRegExp() => RegExp(quotationMarks.join());

  bool isQuotationMark(String char) {
    return quotationMarks.contains(char);
  }
}
