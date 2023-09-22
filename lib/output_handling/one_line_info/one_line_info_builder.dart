import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_parser.dart';
import 'package:winget_gui/widget_assets/link_button.dart';

import '../../helpers/extensions/string_extension.dart';
import '../../widget_assets/link_text.dart';
import '../output_builder.dart';

class OneLineInfoBuilder extends OutputBuilder {
  final List<OneLineInfo> infos;
  OneLineInfoBuilder({required this.infos});

  @override
  Widget build(BuildContext context) {
    return infoWidgets(context);
  }

  Widget infoWidgets(BuildContext context) {
    if (infos.length == 1) {
      return oneLineInfo(infos.single, context);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (OneLineInfo info in infos) oneLineInfo(info, context)]
          .withSpaceBetween(height: 5),
    );
  }

  Widget oneLineInfo(OneLineInfo info, BuildContext context) {
    String details = stripOfQuotationMarks(info.details);
    if (isLink(details)) {
      return LinkButton(url: Uri.parse(details), text: Text(info.title));
    }
    return InfoBar(
      title: Text('${info.title}:'),
      content: details.isNotEmpty ? LinkText(line: details) : null,
      severity: info.severity,
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
