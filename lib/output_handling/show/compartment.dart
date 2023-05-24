import 'package:expandable_text/expandable_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:string_validator/string_validator.dart';
import 'package:winget_gui/extensions/string_map_extension.dart';
import 'package:winget_gui/extensions/widget_list_extension.dart';

import '../info_enum.dart';
import 'link_button.dart';

abstract class Compartment extends StatelessWidget {
  final Map<String, String> infos;
  const Compartment({super.key, required this.infos});

  List<Widget> buildCompartment(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buildCompartment(context),
      ),
    );
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
        body
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
    if (infos.hasEntry(url.key)) {
      return LinkButton(
          url: infos[url.key]!, text: Text(infos[name.key] ?? infos[url.key]!));
    } else {
      return checkIfTextIsLink(context: context, key: name.key);
    }
  }

  Widget checkIfTextIsLink(
      {required BuildContext context, required String key, String? title}) {
    String text = infos[key]!.trim();
    if (isURL(text) ||
        (text.startsWith('ms-windows-store://') && !text.contains(' ')) ||
        (text.startsWith('mailto:') && !text.contains(' ')) &&
            text.contains('@')) {
      return LinkButton(url: text, text: Text(title ?? text));
    }
    return ExpandableText(
      text,
      expandText: 'show more',
      collapseText: 'show less',
      maxLines: 1,
      linkColor: FluentTheme.of(context).accentColor,
    );
  }

  Wrap buttonRow(List<Info> links, BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for (Info info in links)
          if (infos.hasEntry(info.key))
            checkIfTextIsLink(
                context: context, key: info.key, title: info.title),
      ],
    );
  }
}
