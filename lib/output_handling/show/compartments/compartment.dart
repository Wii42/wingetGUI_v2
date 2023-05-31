import 'package:fluent_ui/fluent_ui.dart';
import 'package:string_validator/string_validator.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/widget_assets/link_text.dart';

import '../../../widget_assets//link_button.dart';
import '../../../widget_assets/decorated_box_wrap.dart';
import '../../info_enum.dart';
import '../../infos.dart';

abstract class Compartment extends StatelessWidget {
  final Infos infos;

  const Compartment({super.key, required this.infos});

  List<Widget> buildCompartment(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return DecoratedBoxWrap(
        child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buildCompartment(context),
      ),
    ));
  }

  Wrap wrapInWrap({required String title, required Widget body}) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Text(
            '$title:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body,
      ],
    );
  }

  List<Widget> fullCompartment(
      {String? title,
      List<Widget>? mainColumn,
      Wrap? buttonRow,
      required BuildContext context}) {
    return [
      if (title != null)
        Text(title, style: FluentTheme.of(context).typography.title),
      ...?mainColumn,
      if (mainColumn != null &&
          mainColumn.isNotEmpty &&
          buttonRow != null &&
          buttonRow.children.isNotEmpty)
        const Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: 5),
          child: Divider(),
        ),
      if (buttonRow != null) buttonRow
    ].withSpaceBetween(height: 10);
  }

  Widget textOrLink(
      {required BuildContext context, required Info name, required Info url}) {
    if (infos.allDetails.hasInfo(url)) {
      return LinkButton(
          url: infos.allDetails[url.key]!,
          text: Text(infos.allDetails[name.key] ?? infos.allDetails[url.key]!));
    } else {
      return textWithLinks(key: name.key, context: context);
    }
  }

  Widget checkIfTextIsLink(
      {required BuildContext context, required String key, String? title}) {
    String text = infos.allDetails[key]!.trim();
    if (isURL(text) ||
        (text.startsWith('ms-windows-store://') && !text.contains(' ')) ||
        (text.startsWith('mailto:') && !text.contains(' ')) &&
            text.contains('@')) {
      return LinkButton(url: text, text: Text(title ?? text));
    }
    return textWithLinks(key: key, context: context);
  }

  Widget textWithLinks(
      {required String key, required BuildContext context, int maxLines = 1}) {
    return LinkText(
      line: infos.allDetails[key]!.trim(),
      maxLines: maxLines,
    );
  }

  Wrap buttonRow(List<Info> links, BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for (Info info in links)
          if (infos.allDetails.hasInfo(info))
            checkIfTextIsLink(
                context: context, key: info.key, title: info.title),
      ],
    );
  }
}
