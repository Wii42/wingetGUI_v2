import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_parser.dart';
import 'package:winget_gui/widget_assets/buttons/link_button.dart';

import '../../helpers/extensions/string_extension.dart';
import '../../widget_assets/link_text.dart';

class OneLineInfoBuilder extends StatelessWidget {
  final List<OneLineInfo> infos;
  const OneLineInfoBuilder({super.key, required this.infos});

  @override
  Widget build(BuildContext context) {
    return infoWidgets(context);
  }

  Widget infoWidgets(BuildContext context) {
    if (infos.length == 1) {
      return OneLineInfoWidget(infos.single);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (OneLineInfo info in infos) OneLineInfoWidget(info)]
          .withSpaceBetween(height: 5),
    );
  }

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

class OneLineInfoWidget extends StatelessWidget {
  final OneLineInfo info;
  final void Function()? onClose;
  const OneLineInfoWidget(this.info, {super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    String details = stripOfQuotationMarks(info.details);
    if (StringHelper.isLink(details)) {
      return LinkButton(url: Uri.parse(details), text: Text(info.title));
    }
    return InfoBar(
      title: Text('${info.title}:'),
      content: details.isNotEmpty ? LinkText(line: details) : null,
      severity: info.severity,
      onClose: onClose,
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
    }
    return string;
  }

  static RegExp quotationMarksRegExp() => RegExp(quotationMarks.join());
}
